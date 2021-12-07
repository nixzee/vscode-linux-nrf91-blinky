#!/bin/sh
#$env:DOCKER_BUILDKIT=1
#-----------------------------------------------------------------------------------------
# CI/CD Shell Script
# Decription: The purpose of this script is assit in bootstrapping the CICD needs and 
# create a layer of abstraction so the user doesn't need to remember all commands. It also
# allows the user to run both locally and remotely. A user should be able to run a too at
# any time.
#-----------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
# Globals and init
# Description: Global variables.
#-----------------------------------------------------------------------------------------
# Supported Container Builders
readonly CONTAINER_BUILDER_DOCKER="docker"
readonly CONTAINER_BUILDER_BUILDKIT="buildkit"
# Defaults
readonly DEFAULT_NCS_IMAGE_NAME="ncs"
readonly DEFAULT_NCS_IMAGE_TAG="latest"
readonly DEFAULT_NCS_MR="main"
readonly DEFAULT_NCS_BOARD="nrf9160dk_nrf9160_ns" # Review later
readonly DEFAULT_BUILD_DIR="build"
# Globals
REGISTRY=""
CONTAINER_BUILDER=$CONTAINER_BUILDER_DOCKER
NCS_IMAGE_NAME=$DEFAULT_NCS_IMAGE_NAME
NCS_IMAGE_FULL=""
NCS_BOARD=$DEFAULT_NCS_BOARD
SHA=""
SHORT_SHA=""
BUILD_DIR=$DEFAULT_BUILD_DIR
OS_INFO=""
CMAKE_VERSION=""
PYTHON3_VERSION=""
DTC_VERSION=""
WEST_VERSION=""
GNU_ARM_EMBEDDED_TOOLCHAIN_VERSION=""
ZEPHYR_TOOLCHAIN_VARIANT_ENV=""
GNUARMEMB_TOOLCHAIN_PATH_ENV=""

init()
{
    # Check if local or action...
    # This is janky but it does the job
    ACTION=true
    if [ -z "${GITHUB_RUN_NUMBER}" ]; #Check for env
    then 
        ACTION=false
    fi
    # set based on build enviroment
    if [ $ACTION = true ]
    then # Action
        SHA=${GITHUB_SHA}
        SHORT_SHA=$(git rev-parse --short=4 ${{ GITHUB_SHA }})
    else #Local
        SHA=$(git log -1 --format=%H)
        SHORT_SHA=$(git log -1 --pretty=format:%h)
    fi
    # set the ncs image name
    NCS_IMAGE_FULL="$NCS_IMAGE_NAME:$DEFAULT_NCS_IMAGE_TAG"
    # check if there is a registry
    if [ ! -z "$REGISTRY" ]; 
    then
        NCS_IMAGE_FULL="$REGISTRY/$NCS_IMAGE_FULL"
    fi
    # Get the versions of required tools and enviroment
    # Note: Some of these maybe should be pulled from the dockerfile instead of the host
    # or have seperate variables.
    OS_INFO=$(uname -a)
    CMAKE_VERSION=$(cmake --version 2>/dev/null | tr "\n" " " | cut -d  " " -f 3)
    PYTHON3_VERSION=$(python3 --version 2>/dev/null | cut -d " " -f 2)
    DTC_VERSION=$(dtc --version 2>/dev/null | cut -d " " -f 3)
    WEST_VERSION=$(west --version 2>/dev/null | cut -d " " -f 3)
    GNU_ARM_EMBEDDED_TOOLCHAIN_VERSION=$(arm-none-eabi-gcc --version 2>/dev/null | tr '\n' ' ' | cut -d " " -f 9-10)
    ZEPHYR_TOOLCHAIN_VARIANT_ENV=$(printenv ZEPHYR_TOOLCHAIN_VARIANT)
    GNUARMEMB_TOOLCHAIN_PATH_ENV=$(printenv GNUARMEMB_TOOLCHAIN_PATH)
}

#-----------------------------------------------------------------------------------------
# about
# Description: Use to exit on failed code.
#-----------------------------------------------------------------------------------------
about()
{
    # log
    echo "[Git]"
    echo "SHA: $SHA"
    echo "SHORT_SHA: $SHORT_SHA"
    echo "IN_ACTION: $ACTION"
    echo ""
    echo "[Enviroment]" 
    echo "OS_INFO: $OS_INFO"
    echo "CMAKE_VERSION: $CMAKE_VERSION"
    echo "PYTHON3_VERSION: $PYTHON3_VERSION"
    echo "DTC_VERSION: $DTC_VERSION"
    echo "WEST_VERSION: $WEST_VERSION"
    echo "GNU_ARM_EMBEDDED_TOOLCHAIN_VERSION: $GNU_ARM_EMBEDDED_TOOLCHAIN_VERSION"
    echo "ZEPHYR_TOOLCHAIN_VARIANT_ENV: $ZEPHYR_TOOLCHAIN_VARIANT_ENV"
    echo "GNUARMEMB_TOOLCHAIN_PATH_ENV: $GNUARMEMB_TOOLCHAIN_PATH_ENV"
    echo "NCS_BOARD: $NCS_BOARD"
    echo ""
    echo "[Container]" 
    echo "REGISTRY: $REGISTRY"
    echo "CONTAINER_BUILDER: $CONTAINER_BUILDER"
    echo "NCS_IMAGE_FULL: $NCS_IMAGE_FULL" 
}

#-----------------------------------------------------------------------------------------
# create_build_dir
# Description: Is used by functions to create the build dir
#-----------------------------------------------------------------------------------------
create_build_dir()
{
    # create the build dir with perms
    # BEWARE: if done inside a container with a volume the owner will be root.
    echo "Creating build directory"
    mkdir -p -m777 $BUILD_DIR
}

#-----------------------------------------------------------------------------------------
# remove_build_dir
# Description: Is used by functions to remove the build dir
#-----------------------------------------------------------------------------------------
remove_build_dir()
{
    # Remove the build directory
    echo "Removing build directory"
    rm -rf "$BUILD_DIR"
}

#-----------------------------------------------------------------------------------------
# usage
# Description: Provides the usages of the shell.
#-----------------------------------------------------------------------------------------
usage() 
{
    echo "##############################################################################" 
    echo "Usage" 
    echo "-h for help"
    echo "-a for About - logs meta info std out"
    echo "-m for West Manifest - prints the nRF Connect SDK (ncs) manifest"
    echo "-b for West Build (local) - uses west to build the project"
    echo "-f for West Flash - uses west to erase and flash"
    echo "-d for NCS Image Create - builds the nRF Connect SDK (ncs) container image"
    echo "-r for NCS Image Push - will push the nRF Connect SDK (ncs) image to a registry"
    echo "-x for NCS Image Buid - builds the project with nRF Connect SDK (ncs)"
    echo "-c for Clean - will remove the local build directory and dangling images"
    echo "-s for Clean All - will clean all images and call the clean above"
    echo "##############################################################################" 
}

#-----------------------------------------------------------------------------------------
# status_check
# Description: Use to exit on failed code.
# Yes...I know about set -e. I just perfer to have more control.
# Usage: status_check $?
#-----------------------------------------------------------------------------------------
status_check()
{
    if [ $1 -ne 0 ]
    then
    echo "Terminating"
    exit 1
    fi
}

#-----------------------------------------------------------------------------------------
# west_manifest
# Prints the west manifest
# https://docs.zephyrproject.org/latest/guides/west/manifest.html#west-manifest-cmd
#-----------------------------------------------------------------------------------------
west_manifest()
{
    west list
    status_check $?
    echo ""
}

#-----------------------------------------------------------------------------------------
# west_build
# Description: Will build the artifact local, using west, in build/zephyr/.
# See link for more info: 
# https://docs.zephyrproject.org/latest/guides/west/build-flash-debug.html#building-west-build
#-----------------------------------------------------------------------------------------
west_build()
{
    # build
    echo "Building local with west"
    west build -b $NCS_BOARD
    status_check $?
    echo ""
}

#-----------------------------------------------------------------------------------------
# flash
# Description:Will flash the hex onto the device using West through JLink. Ensure you have 
# built the binary first.
# See link for more info: 
# https://docs.zephyrproject.org/latest/guides/west/build-flash-debug.html#flashing-west-flash
#-----------------------------------------------------------------------------------------
west_flash()
{
    # flash
    echo "Flashing with west"
    west flash
    status_check $?
    echo ""
}

#-----------------------------------------------------------------------------------------
# ncs_image_create
# Description: This section is responsible for building the ncs image.
#-----------------------------------------------------------------------------------------
ncs_image_create()
{
    echo "Prepped for: $NCS_IMAGE_FULL"
    # build
    case $CONTAINER_BUILDER in
        "$CONTAINER_BUILDER_BUILDKIT" ) # For Buildkit
            echo "Using Buildkit"
            docker buildx build . -f ./docker/Dockerfile.ncs -t $NCS_IMAGE_FULL \
                --progress=plain \
                --build-arg GIT_COMMIT="$SHA" \
                --target ncs
            ;;
        "$CONTAINER_BUILDER_DOCKER" ) # For Docker
            echo "Using Docker"
            docker build . -f ./docker/Dockerfile.ncs -t $NCS_IMAGE_FULL \
                --build-arg GIT_COMMIT="$SHA"
            ;;
        * )
            echo "No Container builder is set or not supported"
            status_check 2 
            ;;
    esac
    status_check $?
    echo ""
}

#-----------------------------------------------------------------------------------------
# ncs_image_push
# Description: Will push the ncs images to a registry
#-----------------------------------------------------------------------------------------
ncs_image_push()
{
    echo "Building from container"
    # TODO
    echo ""
}

#-----------------------------------------------------------------------------------------
# ncs_image_build
# Description: Will build the artifacts from the ncs images
#-----------------------------------------------------------------------------------------
ncs_image_build()
{
    echo "Building from container"
    # build
    # docker run --rm -it -v $(pwd):/workspace -exec $NCS_IMAGE_FULL bash -c "cd workspace/ && ./cicd.sh -b" 
    # status_check $?
    echo ""
}

#-----------------------------------------------------------------------------------------
# clean
# Description: Remove build dir and dangling images.
#-----------------------------------------------------------------------------------------
clean()
{
    # remove build dir
    remove_build_dir
    # Remove dangling images
    # This might a little risky since it will delete ALL dangling images
    # but you shouldn't have x number of <none>...
    echo "Removing dangling image(s) if found"
    if [ $(docker images -f "dangling=true" -q) ]; 
    then
        docker rmi -f $(docker images -f "dangling=true" -q)
    fi
    echo ""
}

#-----------------------------------------------------------------------------------------
# clean_all
# Description: Remove the ncs images completely
#-----------------------------------------------------------------------------------------
clean_all()
{
    # Remove ncs images
    echo "Removing ncs image if found"
    if [ $(docker images | grep $NCS_IMAGE_NAME | awk '{print $3}') ]; 
    then
        docker rmi -f $(docker images | grep $NCS_IMAGE_NAME | awk '{print $3}')
    fi
    # Clean
    clean
    echo ""
}



# init
init

# Parse arguements and run
while getopts ":hambfdrxcs" options; do
    case $options in
        h ) usage ;;                # usage (help)
        a ) about ;;                # about
        m ) west_manifest ;;        # prints the manifest
        b ) west_build ;;           # builds the artifacts with West
        f ) west_flash ;;           # flashes with West
        d ) ncs_image_create ;;     # builds the ncs image
        r ) ncs_image_push ;;       # pushes the ncs image to a registry
        x ) ncs_image_build ;;      # builds the artifacts with the ncs container
        c ) clean ;;                # clean
        s ) clean_all ;;            # removes everything
        * ) usage ;;                # default (help)
    esac
done
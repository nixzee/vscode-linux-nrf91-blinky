#!/bin/sh
#$env:DOCKER_BUILDKIT=1
#-----------------------------------------------------------------------------------------
# CI/CD Shell Script
# Decription: The purpose of this script is assit in bootstrapping the CICD needs. It also
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
readonly DEFAULT_TOOLCHAIN="gcc-arm-none-eabi" # Replace to match gnuememememeb
readonly DEFAULT_BUILD_DIR="build"
# Globals
REGISTRY=""
CONTAINER_BUILDER=$CONTAINER_BUILDER_DOCKER
TOOLCHAIN=$DEFAULT_TOOLCHAIN
TOOLCHAIN_VERSION=""
TOOLCHAIN_IMAGE_NAME=""
SHA=""
SHORT_SHA=""
BUILD_DIR=$DEFAULT_BUILD_DIR

# TODO: Correct for this project
init()
{
    # get the toolchain
    # TOOLCHAIN_VERSION=$(grep "ARG ARM_NONE_EABI_PACKAGE_VERSION=" docker/Dockerfile.toolchain | cut -d '"' -f 2)
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
    # set the toolchain image name
    TOOLCHAIN_IMAGE_NAME="$TOOLCHAIN:$TOOLCHAIN_VERSION"
    # check if there is a registry
    if [ ! -z "$REGISTRY" ]; 
    then
        TOOLCHAIN_IMAGE_NAME="$REGISTRY/$TOOLCHAIN_IMAGE_NAME"
    fi
}

#-----------------------------------------------------------------------------------------
# about
# Description: Use to exit on failed code.
#-----------------------------------------------------------------------------------------
about()
{
    # log
    echo "REGISTRY: $REGISTRY"
    echo "CONTAINER_BUILDER: $CONTAINER_BUILDER"
    echo "TOOLCHAIN: $TOOLCHAIN"
    echo "TOOLCHAIN_VERSION: $TOOLCHAIN_VERSION"
    echo "TOOLCHAIN_IMAGE_NAME: $TOOLCHAIN_IMAGE_NAME" 
    echo "SHA: $SHA"
    echo "SHORT_SHA: $SHORT_SHA"
    echo "OS_INFO: $(uname -a)"
    echo "IN_ACTION: $ACTION"
    echo ""
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
    echo "-a for About - logs meta info std out"
    # TODO: Add remaing uses
    echo "##############################################################################" 
}

#-----------------------------------------------------------------------------------------
# build_from_local
# Description: Will build configure create a fresh build dir, configure cmake, and build
# artifacts.
#-----------------------------------------------------------------------------------------
build_from_local()
{
    # TODO
}

#-----------------------------------------------------------------------------------------
# build_from_container
# Description: Will use the tool chain image and call build_from_local inside the 
# container.
#-----------------------------------------------------------------------------------------
build_from_container()
{
    # TODO
}

#-----------------------------------------------------------------------------------------
# clean
# Description: Performs clean up
#-----------------------------------------------------------------------------------------
clean()
{
    # TODO
}

#-----------------------------------------------------------------------------------------
# clean_all
# Description: Performs clean up of everything
#-----------------------------------------------------------------------------------------
clean_all()
{
    # TODO
}

# init
init

# Parse arguements and run
while getopts ":hatbdcs" options; do
    case $options in
        h ) usage ;;                # usage (help)
        a ) about ;;                # about
        # TODO
        * ) usage ;;                # default (help)
    esac
done
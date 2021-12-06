# <img src="https://raw.githubusercontent.com/nixzee/nixzee-branding/master/images/nixzee-logo-base.png" width="100"> vscode-linux-nrf91-blinky

This repo provides everything you will need to get to blinky on the nRF9160 DK with Ubuntu, VScode (with debug), and GitHub CI/CD. Before going any further, I want to thank Edgar and his [nrf53 Blinky repo](https://github.com/edgargrimberg/nrf53_blinky) which was used as a reference.

## Motivation

I wanted the typical Blinky example for my board, the nRF9160 DK, that I could build, debug and flash through VS Code. Yes, I am aware of the nrf extension but I found it to be buggy and I wanted something more native. Additionally, I wanted to be able to do all of this outside of the nrf [SDK](https://github.com/nrfconnect/sdk-nrf) or [Zephyr](https://github.com/zephyrproject-rtos/zephyr) SDKs. I also wanted to have a [GitHub Action](https://github.com/features/actions) that would build the artifacts on a PR. My hope is that you can take this repo and use it as an example in your own projects.

---

## Directory Structure

The project directory structure is broken down as follows:

* [.github/](https://github.com/nixzee/vscode-linux-nRF91-blinky/tree/main/.github/workflows) - Directory that contains GitHub Actions.
* [.vscode/](https://github.com/nixzee/vscode-linux-nRF91-blinky/tree/main/.vscode) - Directory that contains VS Code configurations.
* build/ - Directory that contains the build artifacts. Is captured by the ```.gitignore```.
* [.docker/](https://github.com/nixzee/vscode-linux-nRF91-blinky/tree/main/docker) - Directory that contains the dockerfiles.
* [.src/](https://github.com/nixzee/vscode-linux-nRF91-blinky/tree/main/docker) - Directory that containes the source code. ```main.c``` is the entrypoint.
* cicd.sh - A script that assists with building local or in GitHub.
* prj.conf - A file that is used by [Zephyr's Kconfig](https://docs.zephyrproject.org/latest/application/index.html)

---

## Parts

Below are list of parts to get you to blinky:

* 1x [nRF9160 DK](https://www.nordicsemi.com/Products/Development-hardware/nRF9160-DK/GetStarted)
* 1x Micro USB Cable

---

## OS (Ubuntu 20.04)

This project was developed in [Ubuntu 20.04.2 LTS](https://releases.ubuntu.com/20.04/) server minimal image. You can use another distro but some of instructions below rely on Debian. For my OS, I used [Virtual Box](https://www.virtualbox.org/) since I am lazy. I will not walk you through setting up the OS since there are countless tutorials. My settings are below (mileage may very):

* VDI with dynamic disk space at 20GB.
* Memory is set to 8GB.
* I am using NAT for Network and then port forwarding 22 to 22 (You can mangle if you want) for SSH.
* Post installation I did setup [KDE Minimal Desktop](https://kde.org/) so I could use the [nRF Connect for Desktop GUI](https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-desktop). I have the desktop off by default and enable via ```init 5```.
* I use [ZSH](https://zsh.sourceforge.io/) with [Oh my Shell](https://ohmyz.sh/), instead of BASH because I am a fancy boi and I like my shell to have pretty colors.

---

## Development Tools Setup (Toolchain and Requirements)

To setup the tools you can use the [install manually](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html) instructions found in the nrf sdk documnetation. However, I found a few gotchas and I am not sure you need everything they say you need. Below are my instructions that largely satify the [requirements table](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_recommended_versions.html#gs-recommended-versions).

### Install the Required Tools

1. Add the Kitware APT repository. Perform from the home user directory.

    ```shell
    wget https://apt.kitware.com/kitware-archive.sh
    sudo bash kitware-archive.sh
    ```

2. Install the depedencies as per the instructions.

    ```shell
    sudo apt install --no-install-recommends git cmake ninja-build gperf \
    ccache dfu-util device-tree-compiler wget \
    python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
    make gcc gcc-multilib g++-multilib libsdl2-dev
    ```

3. Install additional depedencies. [Libncurses](https://packages.ubuntu.com/focal/libncurses-dev) is required for the GDB debugger later on.

    ```shell
    sudo apt install build-essential libncurses5 libncurses5-dev
    ```

4. Confirm that the dependencies are installed correctly.

    ```shell
    cmake --version
    python3 --version
    dtc --version
    ```

    Should output something like this:

    ```shell
    cmake version 3.22.0

    CMake suite maintained and supported by Kitware (kitware.com/cmake).
    Python 3.8.10

    Version: DTC 1.5.0
    ```

5. Perform cleanup.

    ```shell
    rm kitware-archive.sh
    ```

### Install West

Click to read more about [West](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/zephyr/guides/west/index.html#west).

1. PIP install West to local user.

    ```shell
    pip3 install --user -U west
    ```

2. Add the ```./local/bin``` to your RC file (mine is ```.zshrc```). I like to manually add to my RC file to keep it organized. You can export is you want.

    Open the file

    ```shell
    nano ~/.zshrc
    ```

    Add this section and save and close:

    ```shell
    # For West
    export PATH=~/.local/bin:"$PATH"
    ```

    Source the file:

    ```shell
    source ~/.zshrc
    ```

3. Confirm West it working.

    ```shell
    west --version
    ```

    Should output something like this:

    ```shell
    West version: v0.12.0
    ```

### Get the nRF Connect SDK

Click here to read up on the [nRF Connect SDK](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/introduction.html#ncs-introduction).

1. From the user home folder create and enter a directory called ```ncs```. This will be used to house the nRF and Zephyr SDKs along with other depedencies, tools, and SVDs.

    ```shell
    mkdir ncs && cd ncs
    ```

2. Initilize West with the nRF Connect SDK and update. This will pull everything and take a few minutes. We will use the ```main``` release.

    ```shell
    west init -m https://github.com/nrfconnect/sdk-nrf --mr main
    west update
    ```

3. Confirm everything is there from the root of the ```ncs``` directory.

    ```shell
    ls -al
    ```

    Should output something like this:

    ```shell
    total 44
    drwxr-xr-x 11 nixzee nixzee 4096 Dec  6 15:31 .
    drwxr-xr-x  6 nixzee nixzee 4096 Dec  6 15:33 ..
    drwxrwxr-x  3 nixzee nixzee 4096 Dec  6 15:30 bootloader
    drwxrwxr-x 15 nixzee nixzee 4096 Dec  6 15:31 mbedtls
    drwxrwxr-x 10 nixzee nixzee 4096 Dec  6 15:32 modules
    drwxrwxr-x 21 nixzee nixzee 4096 Dec  6 15:29 nrf
    drwxrwxr-x 17 nixzee nixzee 4096 Dec  6 15:30 nrfxlib
    drwxrwxr-x  3 nixzee nixzee 4096 Dec  6 15:31 test
    drwxrwxr-x  4 nixzee nixzee 4096 Dec  6 15:32 tools
    drwxrwxr-x  2 nixzee nixzee 4096 Dec  6 15:29 .west
    drwxrwxr-x 22 nixzee nixzee 4096 Dec  6 15:30 zephyr
    ```

### Install Additional Python Dependencies

1. From the root of the ```ncs``` directory, run the following commands. This will take a few minutes.

    ```shell
    pip3 install --user -r zephyr/scripts/requirements.txt
    pip3 install --user -r nrf/scripts/requirements.txt
    pip3 install --user -r bootloader/mcuboot/scripts/requirements.txt
    ```

### Install the GNU Arm Embedded Toolchain

Click to read about [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)

1. From the user home directory, get the GNU Arm Embedded Toolchain and extract to the ```/usr/local```. This is different from the Nordic instructions. I prefer to keep my home directory prsitine. Once extracted cleanup. This will take a few minutes.

    ```shell
    wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2
    sudo tar -C /usr/local -xvf gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2
    rm gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2
    ```

2. Like before, add the toolchain to ```PATH``` in your RC. Addtionally, instead of putting ```GNUARMEMB_TOOLCHAIN_PATH``` in the ```~/.zephyrrc```, I am also adding it to the RC file so that everything is one place. This is my preference and does make it persistent. Note that ```GNUARMEMB_TOOLCHAIN_PATH``` is pointing to ```/usr/local/gcc-arm-none-eabi-9-2019-q4-major```.

    Open the file

    ```shell
    nano ~/.zshrc
    ```

    Add this section and save and close:

    ```shell
    # GNUARMEMB for Zephyr
    export ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
    export GNUARMEMB_TOOLCHAIN_PATH="/usr/local/gcc-arm-none-eabi-9-2019-q4-major"

    # GCC
    export PATH=$PATH:/usr/local/gcc-arm-none-eabi-9-2019-q4-major/bin
    source ~/.zshrc
    ```

    Source the file:

    ```shell
    source ~/.zshrc
    ```

3. Test that ```GCC``` is working.

    ```shell
    arm-none-eabi-gcc --version
    ```

    Should output something like this:

    ```shell
    arm-none-eabi-gcc (GNU Tools for Arm Embedded Processors 9-2019-q4-major) 9.2.1 20191025 (release) [ARM/arm-9-branch revision 277599]
    Copyright (C) 2019 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    ```

4. Test that ```GDB``` is working.

    ```shell
    arm-none-eabi-gdb --version
    ```

    Should output something like this:

    ```shell
    GNU gdb (GNU Tools for Arm Embedded Processors 9-2019-q4-major) 8.3.0.20190709-git
    Copyright (C) 2019 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    ```

### Download nRF Command Line tools

Click to read about the [nRF Command Line Tools](https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools/download).

1. Install unzip since the tools are stored in a zip even for Linux.

    ```shell
    sudo apt-get install unzip
    ```

2. Download the zip of the tools from Nordic and unzip. I recommend create a directory first for easy cleanup later. Make sure you download the latest version. As of writing this, the latest is ```10-15-1```.

    ```shell
    mkdir nrfcommtools && cd nrfcommtools
    wget https://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF-command-line-tools/sw/Versions-10-x-x/10-15-1/nrf-command-line-tools-10.15.1_Linux-amd64.zip
    unzip nrf-command-line-tools-10.15.1_Linux-amd64.zip
    ```

    if you ```ls``` the directory, you should see something like this:

    ```shell
    JLink_Linux_V758b_x86_64.deb
    JLink_Linux_V758b_x86_64.tgz
    nrf-command-line-tools-10.15.1-1.amd64.rpm
    nrf-command-line-tools_10.15.1_amd64.deb
    nrf-command-line-tools-10.15.1_Linux-amd64.tar.gz
    nrf-command-line-tools-10.15.1_Linux-amd64.zip
    ```

3. Install the ```JLink``` and ```nrf-command-line-tools``` debian packages. Make sure to update the version if different.

    ```shell
    sudo dpkg -i JLink_Linux_V758b_x86_64.deb
    sudo dpkg -i nrf-command-line-tools_10.15.1_amd64.deb
    sudo apt-get install -f
    ```

4. Confirm ```JLink``` is working.

    ```shell
    JLinkExe --version
    ```

    Should output something like this:

    ```shell
    SEGGER J-Link Commander V7.58b (Compiled Nov 16 2021 15:04:43)
    DLL version V7.58b, compiled Nov 16 2021 15:04:27
    ```

5. Confirm ```nrf-command-line-tools``` is working.

    ```shell
    nrfjprog --version
    ```

    Should output something like this:

    ```shell
    nrfjprog version: 10.15.1 external
    JLinkARM.dll version: 7.58b
    ```

### Confirm Its Working

At this point, you should be able to build and flash from command line. This section will test that.

1. Navigate to the nRF9160 AT Client sample.

    ```shell
    cd ncs/nrf/samples/nrf9160/at_client
    ```

2. Build the sample using the ```nrf9160dk_nrf9160_ns``` board arguement. This is specifying to build for the nRF9160 DK in non-secure. This will take a few minutes the first time.

    ```shell
    west build -b nrf9160dk_nrf9160_ns
    ```

3. Finally, flash it. If you are using a VM, don't forget to attach the device. For Virtual Box on my machine, I select ```Devices >> USB >> Segger J-Link```.

    ```shell
    west flash
    ```

    The output will look something like this:

    ```shell
    -- west flash: rebuilding
    [0/11] Performing build step for 'spm_subimage'
    ninja: no work to do.
    -- west flash: using runner nrfjprog
    Using board 960094144
    -- runners.nrfjprog: Flashing file: /home/nixzee/ncs/nrf/samples/nrf9160/at_client/build/zephyr/merged.hex
    Parsing image file.
    Verified OK.
    Applying pin reset.
    -- runners.nrfjprog: Board with serial number 960094144 flashed successfully.
    ```

---

## Development Enviroment Setup (VS Code IDE)

This project makes use of [VS Code](https://code.visualstudio.com) as its IDE. I prefer VS Code because its free and runs on anything, stable, many extensions, and can be used with many languages. This project makes use of some extensions like Cortex-Debug and C/C++ IntelliSense. More info and instructions below.

TODO

---

## Building and Debug

TODO

---

## GitHub CI/CD

TODO

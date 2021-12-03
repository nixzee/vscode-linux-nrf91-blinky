# <img src="https://raw.githubusercontent.com/nixzee/nixzee-branding/master/images/nixzee-logo-base.png" width="100"> vscode-linux-nrf96-blinky

This repo provides everything you will need to get to blinky on the nRF9160 DK with Ubuntu, VScode (with debug), and GitHub CI/CD. Before going any further, I want to thank Edgar and his [nrf53 Blinky repo](https://github.com/edgargrimberg/nrf53_blinky) which was used as a reference.

## Motivation

I wanted the typical Blinky example for my board, the nRF9610 DK, that I could build, debug and flash through VS Code. Yes, I am aware of the nrf extension but I found it to be buggy and I wanted something more native. Additionally, I wanted to be able to do all of this outside of the nrf [SDK](https://github.com/nrfconnect/sdk-nrf) or [Zephyr](https://github.com/zephyrproject-rtos/zephyr) SDKs. I also wanted to have a [GitHub Action](https://github.com/features/actions) that would build the artifacts on a PR. My hope is that you can take this repo and use it as an example in your own projects.

---

## Directory Structure

The project directory structure is broken down as follows:

* [.github/](https://github.com/nixzee/vscode-linux-nrf96-blinky/tree/main/.github/workflows) - Directory that contains GitHub Actions.
* [.vscode/](https://github.com/nixzee/vscode-linux-nrf96-blinky/tree/main/.vscode) - Directory that contains VS Code configurations.
* build/ - Directory that contains the build artifacts. Is captured by the ```.gitignore```.
* [.docker/](https://github.com/nixzee/vscode-linux-nrf96-blinky/tree/main/docker) - Directory that contains the dockerfiles.
* [.src/](https://github.com/nixzee/vscode-linux-nrf96-blinky/tree/main/docker) - Directory that containes the source code. ```main.c``` is the entrypoint.
* cicd.sh - A script that assists with building local or in GitHub.
* prj.conf - A file that is used by [Zephyr's Kconfig](https://docs.zephyrproject.org/latest/application/index.html)

---

## Parts

Below are list of parts to get you to blinky:

* 1x [nRF9610 DK](https://www.nordicsemi.com/Products/Development-hardware/nRF9160-DK/GetStarted)
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

TODO

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

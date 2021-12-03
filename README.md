# <img src="https://raw.githubusercontent.com/nixzee/nixzee-branding/master/images/nixzee-logo-base.png" width="100"> vscode-linux-nrf96-blinky

This repo provides everything you will need to get to blinky on the nrf9160dk with Ubuntu, VScode (with debug), and GitHub CI/CD. Before going any further, I want to thank Edgar and his [nrf53 Blinky repo](https://github.com/edgargrimberg/nrf53_blinky) which was used as a reference.

## Motivation

TODO

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

## OS Setup (Ubuntu 20.04)

This project was developed in [Ubuntu 20.04.2 LTS](https://releases.ubuntu.com/20.04/) server minimal image. You can use another distro but some of instructions below rely on Debian. For my OS, I used [Virtual Box](https://www.virtualbox.org/) since I am lazy. My settings are below (milage may very):

* VDI with dynamic disk space at 20GB.
* Memory is set to 8GB.
* I am using NAT for Network and then port forwarding 22 to 22 (You can mangle if you want) for SSH.
* Post installation I did setup [KDE Minimal Desktop](https://kde.org/) so I could use the [nRF Connect for Desktop GUI](https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-desktop). I have the desktop off by default and enable via ```init 5```.

---

## Development Tools Setup (Toolchain and Deps)

TODO

---

## Development Enviroment Setup (VS Code IDE)

TODO

---

## Building and Debug

TODO

---

## GitHub CI/CD

TODO

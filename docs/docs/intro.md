---
sidebar_position: 1
---

# Tutorial Intro

Let's discover **The Saturn Launcher in less than 5 minutes**.

## Getting Started

Get started by **installing Saturn Launcher**.

### What you'll need

- [KDE Plasma](https://kde.org) (or a distro that comes with it)

## Installing Saturn Launcher

To install the launcher, clone or download the source code (no releases yet).

Then, run the following commands:

```bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=YOUR_PREFIX_HERE ..
sudo make install
```
replace "YOUR_PREFIX_HERE" with a valid path to you KDE Plasma Widgets.

## Replace the default launcher

To replace the default launcher with Saturn, right-click the button you use to launch regular

applications. Then click the item that **should** say "Alternatives". Finally, choose "Saturn Launcher".

Congratulations! You have now successfully setup the Saturn Launcher.


## Is this needed on Tridentu-RK?

No. The reason: Saturn Launcher is built into Tridentu-RK by default.

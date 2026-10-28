# Instructions for the AVerMedia D315 with a 32GB AGX Orin

These are the flashing instructions for the AVerMedia D315 carrier board fitted
with a **32GB** Jetson AGX Orin module. For the 64GB module see
[AVerMedia D315 AGX Orin 64GB](../README.md#avermedia-d315-agx-orin-64gb).

The D315 is a custom carrier board for the same AGX Orin SoM used by the NVIDIA
devkit, so with a 32GB module it is flashed exactly like the
[Jetson AGX Orin Devkit 32GB](./jetson-agx-orin-devkit.md): the stock NVIDIA L4T
BSP is used, and the D315 carrier-board-specific files from the AVerMedia BSP are
copied into the BSP tree before `flash.sh` runs. No USB flasher stick is involved.

> The 64GB module uses a different process (`Orin_Flash/flash_orin.sh`, RCM boot
> plus a flasher image on a USB stick) because balena only supplies a flasher
> image for the `jetson-agx-orin-devkit-64gb` device type.

## What this tool does for the D315

Before invoking NVIDIA's `flash.sh` it copies these files from
`Orin_Flash/avermedia-d315/` into the L4T tree:

| File | Destination in `Linux_for_Tegra` |
|------|----------------------------------|
| `jetson-agx-orin-d315ao.conf` | `./` |
| `tegra234-p3737-0000+p3701-000{0,4,5}-nv-d315.dtb` | `kernel/dtb/` |
| `tegra234-mb1-bct-pinmux-p3701-0000-a04.dtsi` | `bootloader/generic/BCT/` |
| `tegra234-mb1-bct-gpio-p3701-0000-a04.dtsi` | `bootloader/` |

`flash.sh` is then run with the `jetson-agx-orin-d315ao` board configuration
instead of `jetson-agx-orin-devkit`. That configuration is AVerMedia's copy of
the stock `jetson-agx-orin-devkit.conf`, differing only in the device tree it
selects from the module SKU read off the SoM EEPROM (`0000`/`0001`/`0002` and
`0004` are the 32GB SKUs).

All of the files above are taken verbatim from `Linux_for_Tegra/settings/D315/`
of AVerMedia's JetPack 7.2 BSP (`AVERMEDIA_JETPACK-R4.0.2.7.2.0`), which matches
the L4T 39.2.0 release this tool downloads. Refresh them from `settings/D315/`
whenever the L4T release in `lib/resin-jetson-flash.js` is bumped.

`p3701.conf.common` is deliberately left alone: AVerMedia's copy differs from the
stock 39.2.0 one only in `CMDLINE_ADD`, and theirs is the older kernel command
line, so the stock file from the downloaded BSP is used instead.

## balenaOS image

Use a balenaOS image built for the **`jetson-agx-orin-devkit`** device type. That
image ships `/boot/tegra234-p3737-0000+p3701-0000-nv-d315.dtb` alongside the
stock devkit DTB, which is what the flashed board boots.

## Requirements

- An x86 Linux host with Docker installed, and the Docker image run as privileged
- `/dev/bus/usb` bind-mounted so the Tegra BSP tools can talk to the device
- The unpacked balenaOS image placed in `~/images/` on the host

## Recovery mode

Put the D315 in USB recovery mode: power the board off, connect the micro-USB /
Type-C cable used for flashing to the host, hold the force recovery button and
power the board on.

Confirm with:

```sh
$ lsusb | grep NVIDIA
Bus 003 Device 005: ID 0955:7023 NVIDIA Corp. APX
```

(The `APX` is what confirms recovery mode.)

## Run the tool

Build the container:

```sh
./build.sh -m avermedia-d315-agx-orin-32gb
```

Then flash in a single command:

```sh
docker container run --rm -it --privileged \
    -v /dev/bus/usb:/dev/bus/usb \
    -v ~/images:/data/images \
    jetson-flash-image \
    ./bin/cmd.js -f /data/images/<balena.img> \
                 -m avermedia-d315-agx-orin-32gb \
                 --accept-license=yes
```

Without Docker, from a checkout with `npm install` already run:

```sh
$ ./bin/cmd.js -f <balena.img> -m avermedia-d315-agx-orin-32gb
```

The flashing process takes 5 - 15 minutes. On success you will see:

```
*** The target t186ref has been flashed successfully. ***
Reset the board to boot from internal eMMC.
```

Power-cycle the board out of recovery mode to boot balenaOS.

## Support

If you're having any problems, please [raise an issue](https://github.com/balena-os/jetson-flash/issues/new) on GitHub or ask a question [in our forums](https://forums.balena.io/c/share-questions-or-issues-about-balena-jetson-flash-which-is-a-tool-that-allows-users-to-flash-balenaos-on-nvidia-jetson-devices/95) and the balena.io team will be happy to help.

License
-------

The project is licensed under the Apache 2.0 license.

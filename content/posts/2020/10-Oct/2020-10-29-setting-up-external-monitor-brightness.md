---
title: Setting up External Monitor Brightness Controls on Arch Linux
date: 2020-10-29 16:30:00 -0600
categories: [Tutorials, Linux]
tags: [tutorial, linux, computers]     # TAG names should always be lowercase
pin: no
---

This will be the first technical post on my website. I will use this post to describe the process in setting up external brightness control in Sway on Arch Linux.

## Background

Kernel 5.9 added improved I2C support to Navi 10 cards[^kernel-footnote], which include the Radeon RX 5600XT. Using I2C in combination with [ddcutil](https://www.archlinux.org/packages/community/x86_64/ddcutil/) can allow us to control an external monitors brightness using commands.

## Using ddcutil

### Detecting Monitors

First we need to make sure that the ```i2c-dev``` module is loaded into the system; In my case, it was loaded automatically. We now want to identify the monitors:

```console
# ddcutil detect
Display 1
   I2C bus:             /dev/i2c-5
   EDID synopsis:
      Mfg id:           GSM
      Model:            LG QHD
      Serial number:
      Manufacture year: 2020
      EDID version:     1.4
   VCP version:         2.1

Display 2
   I2C bus:             /dev/i2c-6
   EDID synopsis:
      Mfg id:           DEL
      Model:            DELL P2014H
      Serial number:    J6HFT3B9AK7L
      Manufacture year: 2013
      EDID version:     1.4
   VCP version:         2.1
```

The monitor I am interested in is the LG QHD, with a bus number of 5. ```ddcutil``` can change various properties of connected monitors, we are only interested i brightness right now.

We want to get current brightness value. We can use the ```ddcutil getvcp``` command to get our current value. The id for brightness is 10, so we can get our brightness value:

```console
# ddcutil --bus 5 getvcp 10
VCP code 0x10 (Brightness                    ): current value =   100, max value =   100
```

We can see that the range for the brightness on this monitor is 0 to 100.

### Adjusting Brightness

We can change the brightness by using the ```ddcutil setvcp``` command. We also need to use the ```--bus``` parameter to specify which monitor we want to adjust. For example, to set the brightness to 50:

```console
# ddcutil --bus 5 setvcp 10 50
```

Brightness can also be set relatively:

```console
# ddcutil --bus 5 setvcp 10 - 5
```

lowers the brightness by 5. The ```-``` can be replaced with a ```+``` to increase the brightness instead.

Now that we know the commands, we can now figure out how to bind the command to a shortcut in our display manager, which is Sway in my case.

There is a problem: all the commands we have run require root access, we don't have access to ```/dev/i2c-5```.

```console
$ ddcutil --bus 5 setvcp 10 - 5
Open failed for /dev/i2c-5: errno=EACCES(13): Permission denied
No monitor detected on I2C bus /dev/i2c-5
```

## Permitting user access to ```/dev/i2c-*```

I follow the instructions layed out [here](https://lexruee.ch/setting-i2c-permissions-for-non-root-users.html). Here is a summary:

Create group ```i2c```:

```console
# groupadd i2c
```

Add your user to ```i2c``` group:

```console
# usermod -aG i2c lsanche
```

Create a udev rule to make the changes permanent:

```console
# echo 'KERNEL=="i2c-[0-9]*", GROUP="i2c"' >> /etc/udev/rules.d/10-local_i2c_group.rules
```

Reboot and test it out.

When I attempt to change the brightness command again as a non-root user, it is now successful.

Now it is time to implement the shortcuts into Sway.

## Setting Up Sway Shortcuts

This part is quick and easy. I wanted to be able to hold the Windows key and press F11 or F12 to adjust brightness, so this is what I put into my Sway config:

```
### Brightness Controls ###
bindsym $mod+F12 exec ddcutil --bus 5 setvcp 10 + 10
bindsym $mod+F11 exec ddcutil --bus 5 setvcp 10 - 10
bindsym ctrl+$mod+F12 exec ddcutil --bus 5 setvcp 10 100
bindsym ctrl+$mod+F11 exec ddcutil --bus 5 setvcp 10 0
```

You can see I have also added the same combos, but with the control key added as I wanted a way to quickly make the monitor the brightest or darkest as possible.

And that's it! Enjoy your new DIY brightness controls for your external monitor.

[^kernel-footnote]: Commit adding this support can be found [here](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1bc734759f284eb531dd474c72ce59874649a254).

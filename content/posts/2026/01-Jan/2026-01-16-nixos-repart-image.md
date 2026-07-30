---
title: Reproducable, flashable, updateable Raspberry Pi Images with NixOS
date: 2026-01-16 07:30:00 -0600
categories: [Tutorials]
tags: [nix, nixos, systemd, repart, sysupdate, raspberry, pi, embedded, kiosk, linux, image, update, deployment, cross, compile, minimal, secure, compression]     # TAG names should always be lowercase
pin: no
aliases:
  - /posts/nixos-repart-image/
---

A lot of my knowledge laid out here would not be possible without the insight
from
[Nixcademy](https://nixcademy.com/posts/auto-growing-nixos-appliance-images-with-systemd-repart/)
and their blog series on NixOS images. Please check out the linked blog for more
information on this topic. The code in this article is heavily inspired by or
reused from that post.

I hope to add a little more to this topic by showing how to achieve a UEFI-based
image for a Raspberry Pi. I also want to practice my technical writing skills
for this article.

AI was only used for basic spelling and grammar. The words are my own

# Background

I have been using NixOS for almost half a decade. I have completely immersed
myself in it. I use it for my laptop, desktop, VPS, and a little Raspberry Pi 4.
I have recently started using it in professional life, which has encouraged me to
think of its other use cases.

On a desktop or server system, NixOS is great for the atomic updates and
rollbacks, declarative configuration, reproducibility, and module system. This
is great when you want a system that can be quickly modified and updated and
have the resources to do so.

On an embedded device, resources may be restricted. Disk space, memory, CPU
speed, and network access are all things that can be limited on an embedded system.
We may also want to limit specific functionality of the system to reduce attack
surface or resource usage.

My experience so far with NixOS is that it is not optimized for these low
resource situations by default, but can be made to fit these use cases! Nix and
NixOS provide a pathway to a fully custom Linux build for almost any requirement.

NixOS uses the systemd suite of software for the init system and optionally
networking, time synchronization, boot loader, among others. The existence of
systemd in the NixOS stack means we have access to some very interesting and
useful pieces of software:

- [systemd-repart](https://www.freedesktop.org/software/systemd/man/latest/systemd-repart.html) for building images and partitioning drives.
- [systemd-sysupdate](https://www.freedesktop.org/software/systemd/man/latest/systemd-sysupdate.html) for image-based update mechanisms.
- [systemd-boot](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html) for the bootloader. This enables features such as boot
  counting.
- [systemd-networkd](https://www.freedesktop.org/software/systemd/man/latest/systemd-networkd.html) for declarative network configuration.
- [systemd-firstboot](https://www.freedesktop.org/software/systemd/man/latest/systemd-firstboot.html) for configuring a system on first boot.
- [systemd-cryptenroll](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html) for easy setup of TPM-backed encryption.

I am brain dumping this article (and hopefully more) to hopefully provide some
insight and clarity on how NixOS can fit in your desktop and embedded world.

# The Problem

NixOS already provides an easy way to get started with defining a computer
configuration. Using flakes, we can even lock our dependencies down in such a
way that we can reproduce the same result over and over. Here is a simple
example:

```nix
{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ...} @ inputs: {
    nixosConfigurations.raspberry-pi = nixpkgs.lib.nixosSystem {
      modules = [
        # Generic NixOS configuration
        ./configuration.nix
        {
          # Set the host arch
          nixpkgs.hostPlatform = "aarch64-linux";
        }
      ]
    }
  }
}
```

With the above flake, it is trivial to build the NixOS configuration on the
target machine and switch to it with something like:

```ShellSession
# nixos-rebuild switch --flake .#raspberry-pi
```

This is great and gets us most of the way there. We are not all the way there
yet, however. How do we get NixOS on our device in the first place?

## Initial Deployment

Our target device is a Raspberry Pi. Out of the box, the Pi does not come with
UEFI firmware, which would allow us to just plug in an installer USB and
continue on our way to installation. Now we can get it set up this way, and we
will (see [here](https://github.com/pftf/RPi4)), but wouldn't it be nice if we
could directly deploy our desired configuration to a Pi SD card without any
additional interaction?

## Automatic Updates

Our device is a lower-power unit but still capable of running Nix to build and
apply simple updates. For more complex configurations which involve more code
compilation, it is desirable to build our system off-device and deploy it after
it is built.

Nix has built-in support for booting into multiple past generations of a system.
For our usage, a simple A/B partitioning scheme will suffice and can simplify
our deployment greatly.

## Future Considerations

This is out of scope for this article, but other functionalities like using
dm-verity for checking our OS data against a hash, secure boot for only loading
signed software, and automatic rollbacks on failure are desirable features to be
explored in the future.

# The Solution

Let's explore the uses of two systemd tools: `systemd-repart` and
`systemd-sysupdate`.

## Image Deployment

The goal is to be able to use Nix to generate an appliance image we can deploy
directly to an SD card and boot on a Pi. Some desirables for this method:

- Minimal compressed image with no wasted space.
- Full partition table contained within.
- Separate Nix store partitions for A/B updates later on.
- On first boot, automatically grow or create required partitions to fill
  available space.

systemd-repart can solve this for us. From the
[docs](https://www.freedesktop.org/software/systemd/man/latest/systemd-repart.html):

> **systemd-repart** is used when building OS images, and also when deploying images
> to automatically adjust them, during boot, to the system they are running on.
> This way the image can be minimal in size and may be augmented automatically
> at boot, taking possession of the disk space available.

NixOS has support for repart in the module system for runtime configuration of
partitions on the device. For image creation, NixOS has the
[repart.nix](https://github.com/NixOS/nixpkgs/blob/0953fdba8af00798dafbeae5626523320fd170ac/nixos/modules/image/repart.nix)
profile that can be imported to expose a derivation in the system configuration
to build an image that can be used to deploy a configuration. We will use this
module to build our Raspberry Pi image.


```nix
imports = [
  (modulesPath + "/image/repart.nix")
];

system.image = {
  id = "trinity";
  version = "v0";
};

image.repart = {
  name = config.system.image.id;
  compression.enable = true;
  split = true;

  partitions = {
    "10-esp" = {
      contents = {
        "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source = "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

        "/EFI/Linux/${config.system.boot.loader.ukiFile}".source = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";

        "/loader/loader.conf".source = builtins.toFile "loader.conf" ''
          timeout 5
        '';

        "/".source = inputs.rpi4-uefi;
      };
      repartConfig = {
        Format = "vfat";
        Label = "boot";
        SizeMinBytes = "200M";
        Type = "esp";
        SplitName = "-";
      };
    };
    "20-nix-store" = {
      storePaths = [config.system.build.toplevel];
      nixStorePrefix = "/";
      repartConfig = {
        Format = "squashfs";
        Label = "nix-store_${config.system.image.version}";
        Minimize = "off";
        SizeMinBytes = storeSize;
        SizeMaxBytes = storeSize;
        ReadOnly = "yes";
        Type = "linux-generic";
        SplitName = "nix-store";
      };
    };
    "30-empty" = {
      repartConfig = {
        Label = "_empty";
        Minimize = "off";
        SizeMinBytes = storeSize;
        SizeMaxBytes = storeSize;
        Type = "linux-generic";
        SplitName = "-";
      };
    };
  };
};
```

In your `flake.nix` you would have this in your `inputs`:

```nix
rpi4-uefi = {
  url = "https://github.com/pftf/RPi4/releases/download/v1.50/RPi4_UEFI_Firmware_v1.50.zip";
  flake = false;
};
```

The above configuration sets up an output image that can be used to flash to an
SD card. Some things are set up for later, like the "_empty" partition. This
image currently contains one ESP partition and two nix store partitions, one
being empty and one containing our NixOS configuration. We manually specify the
size so that it is predictable.

Squashfs is being used for the store partitions as it achieves solid compression
ratios to reduce the size of our image. Unless we are doing high I/O on the
nix store, which is unlikely, this should be fine. If we want to trade off some
compression for more performance, erofs is an option that repart is compatible
with. Other options like ext4, xfs, etc., will also work here.

We also compress the entire image (zstd by default) so that our local nix store
does not fill up too fast. This compresses down the empty partition completely.

We need to also set up our image to create a root partition on first boot. Let's
do that now:

```nix
boot = {
  initrd.systemd = {
    enable = true;
    emergencyAccess = true;
    repart = {
      enable = true;
      device = "/dev/mmcblk1";
    };
  };
};

systemd = {
  repart.partitions = {
    root = {
      Format = "xfs";
      Label = "root";
      Type = "root";
      Weight = 1000;
    };
  };
};
```

We enable repart in the initrd to enable creating the root partition on first
boot. I also enable emergency access so if this does not work, I can log in to
an emergency shell to see what went wrong.

> **NOTE** I set `/dev/mmcblk1` as that is what my SD card was linked to **most** of the
> time. I have not figured out a way to get more specific on my Pi, as sometimes
> it boots on `mmcblk0`.

Now when we boot our device, a root partition will be automatically created,
removing our need to include it in the initial image. To tie this all together
and make it bootable, we can add our mount points to the configuration:

```nix
fileSystems = {
  "/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "xfs";
  };
  "/boot" = {
    device = "/dev/disk/by-partlabel/boot";
    fsType = "vfat";
  };
  "/nix/store" = {
    device = "/dev/disk/by-partlabel/nix-store_${config.system.image.version}";
    fsType = "squashfs";
  };
};
```

This utilizes partition labels to ensure we always boot the correct device.

### Shrinking it Down

Since we are creating an image for our configuration, we might as well try and
make it smaller. I found this configuration to get me most of the way there:

```nix
imports = [
  (modulesPath + "/profiles/minimal.nix")
  (modulesPath + "/profiles/image-based-appliance.nix")
  (modulesPath + "/profiles/perlless.nix")
];
```

What do these modules do?

- `minimal`: Disables most documentation and other programs like logrotate and
  xdg.
- `image-based-appliance`: Disables the nix package manager entirely and
  switches to systemd for the initrd and networking.
- `perlless`: Switches to non-Perl alternatives to some default services and
  enforces a zero-Perl policy.

I found this to reduce my closure size a bit, and thus the image. Note that
without Nix, an alternative mechanism will be required to update the system.
This is what I will cover next.

## Updates

So far we have produced an image for initial deployment for a Raspberry Pi, but
we cannot yet update it. Let's solve this problem now.

We are going to use systemd-sysupdate to deploy updates to our device. In the
previous code outlining the repart configuration, we had an option for
`split = true` in the configuration. This instructs systemd-repart to not only produce
our image but to produce files for each partition of that image. This allows us
to deploy updates by distributing our Nix store and kernel with no
unnecessary extras.

Here is the relevant host-side repart configuration:

```nix
systemd.sysupdate = {
  enable = true;
  transfers = let
    updateSource = {
      Path = "http://localhost/";
      Type = "url-file";
    };
  in {
    "10-nix-store" = {
      Source =
        updateSource
        // {
          MatchPattern = ["${config.system.image.id}_@v.nix-store.raw.zst"];
        };

      Target = {
        InstancesMax = 2;
        Path = "auto";
        MatchPattern = "nix-store_@v";
        Type = "partition";
        ReadOnly = "yes";
      };

      Transfer.Verify = "no";
    };
    "20-boot-image" = {
      Source =
        updateSource
        // {
          MatchPattern = ["${config.boot.uki.name}_@v.efi"];
        };
      Target = {
        # only keep 2 kernel images in the ESP partition
        InstancesMax = 2;
        MatchPattern = ["${config.boot.uki.name}_@v.efi"];
        Mode = "0444";
        Path = "/EFI/Linux";
        PathRelativeTo = "boot";
        Type = "regular-file";
      };

      Transfer.Verify = "no";
    };
  };
};
```

This defines rules to update both our nix store and the unified kernel image
file. We define a maximum of two instances as we have only configured two nix
store partitions. This can be configured for more if desired.

The partition labels and image files are configured to follow a specific file
naming format. The sysupdate service uses the names of the partitions and files
to determine how the updates are to be applied. In this case, our nix store is
updated via partitioning while the kernel is a single unified kernel image file
being saved into our ESP.

We currently instruct sysupdate to look at localhost for update files. You can
use the default configuration of lighttpd to serve updates at `/srv/www` via:

```nix
services.lighttpd.enable = true;
```

Or use your web server of choice.

Verifying the download with GPG is disabled for testing purposes only.

We define an output for our configuration to define a sysupdate "package":

```nix
system.build.sysupdate-package = let
  inherit (config.system) build;
  inherit (config.system.image) version id;
in
  pkgs.runCommand "sysupdate-package-${version}" {} ''
    mkdir $out
    cp ${build.uki}/${config.system.boot.loader.ukiFile} $out/
    cp ${build.image}/${id}_${version}.nix-store.raw.zst $out/
    cd $out
    sha256sum * > SHA256SUMS
  '';
```

This derivation builds a "package" containing the unified kernel image and
nix-store image that we can use to deploy updates to our Raspberry Pi. A
SHA256SUMS file is also built so we can verify the integrity of the files.

This just copies all of our image files into one spot that we can deploy by
copying to `/srv/www` on the imaged system.

We then copy the contents of this package to the `/srv/www` folder on our
Raspberry Pi through SSH or your preferred method.

Applying the update is as easy as:

```ShellSession
# updatectl update
```

A nice progress bar is shown to indicate the progress of the operation. Once
finished, a reboot will take you to the new version.

In this case, we have two image partitions. With this, we still have our previous
revision available to boot on the bootloader screen.

# Conclusion

What has been demonstrated here is how to create images suitable for embedded
deployments of NixOS.

What I find to be the most interesting about this is how systemd has made itself
useful in almost all aspects of making a Linux distribution. The way all the
pieces fit together and are configured really demonstrates cohesiveness when
other systems may not feel so simple.

Systemd is a topic I am going to explore in future posts. Specifically, I am
interested in replacing every part of my system for which systemd has a counterpart.
It will be an experiment, and we will see if it is a positive or negative
experience for my desktop Linux workflow.

The source for my system in this article can be found [here](https://github.com/Lyndeno/nix-config/blob/ba5528c5b638713adb43b680559f1b4edabccde8/hosts/trinity/configuration.nix).

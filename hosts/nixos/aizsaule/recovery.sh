#!/bin/bash

# This script performs a recovery of the aizsaule computer.

# Prompt user for the encryption password.
IFS= read -r -s -p "Enter disk encryption password: " PASSWORD
echo

# Decrypt root partition.
echo "$PASSWORD" | cryptsetup --batch-mode open /dev/nvme0n1p2 nixos-enc

# Mount the root partition.
mount -o subvol=root,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt
mount --mkdir -o subvol=nix,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt/nix
mount --mkdir -o subvol=persist,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt/persist
mount --mkdir -o subvol=swap /dev/mapper/nixos-enc /mnt/swap
mount --mkdir -o subvol=home,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt/home

# Turn on swap
swapon /mnt/swap/swapfile

# Mount boot partition.
mount --mkdir -o umask=077 /dev/disk/by-label/boot /mnt/boot

#!/bin/bash

# This script performs the installation of the auseklis computer.

# Partition main disk.
wipefs --all --force --quiet /dev/nvme0n1
parted --script --align optimal /dev/nvme0n1 \
  mklabel gpt \
  mkpart esp fat32 1MiB 4097MiB \
  set 1 esp on \
  mkpart root btrfs 4097MiB 100% \
  type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709

# Partition second disk.
wipefs --all --force --quiet /dev/nvme1n1
parted --script --align optimal /dev/nvme1n1 \
  mklabel gpt \
  mkpart root btrfs 0% 100% \
  type 1 0FC63DAF-8483-4772-8E79-3D69D8477DE4

# Prompt user for the encryption password.
IFS= read -r -s -p "Enter disk encryption password: " PASSWORD
echo

# Encrypt root partition.
echo "$PASSWORD" | cryptsetup --batch-mode --hash sha512 --iter-time 10000 --label nixos-crypt luksFormat /dev/nvme0n1p2
echo "$PASSWORD" | cryptsetup --batch-mode open /dev/nvme0n1p2 nixos-enc

# Encrypt second disk.
echo "$PASSWORD" | cryptsetup --batch-mode --hash sha512 --iter-time 10000 --label data-crypt luksFormat /dev/nvme1n1p1
echo "$PASSWORD" | cryptsetup --batch-mode open /dev/nvme1n1p1 data-enc

# Format and mount root partition.
mkfs.btrfs --label nixos --force --quiet /dev/mapper/nixos-enc
mount /dev/mapper/nixos-enc /mnt
btrfs --quiet subvolume create /mnt/root
btrfs --quiet subvolume create /mnt/nix
btrfs --quiet subvolume create /mnt/persist
btrfs --quiet subvolume create /mnt/swap
btrfs --quiet subvolume create /mnt/home
btrfs --quiet subvolume snapshot -r /mnt/root /mnt/root-blank
umount /mnt
mount -o subvol=root,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt
mount --mkdir -o subvol=nix,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt/nix
mount --mkdir -o subvol=persist,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt/persist
mount --mkdir -o subvol=swap /dev/mapper/nixos-enc /mnt/swap
mount --mkdir -o subvol=home,noatime,compress-force=zstd:1 /dev/mapper/nixos-enc /mnt/home
btrfs --quiet filesystem mkswapfile --size 64g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# Format and mount boot partition.
mkfs.fat -F 32 -n boot /dev/nvme0n1p1 >/dev/null 2>&1
mount --mkdir /dev/nvme0n1p1 /mnt/boot

# Format and mount second disk.
mkfs.btrfs --label data --force --quiet /dev/mapper/data-enc
mount --mkdir /dev/mapper/data-enc /mnt/data
btrfs --quiet subvolume create /mnt/data/data
umount /mnt/data
mount --mkdir -o subvol=data,noatime,compress-force=zstd:1 /dev/mapper/data-enc /mnt/data

# Setup machines sops-nix secret key
mkdir --parents /mnt/persist/sops/secrets/age
nix-shell --quiet -p age --run 'age-keygen -o /mnt/persist/sops/secrets/age/key.txt'
read -r -p "Add this public key to sops as auseklis. When done, press enter to continue."

# Create secure boot keys. Note need to update channel for newer version of sbctl.
nix-channel --add https://channels.nixos.org/nixos-unstable-small nixos
nix-channel --update >/dev/null 2>&1
nix-shell --quiet -p sbctl --run 'sbctl --quiet create-keys --export /mnt/persist/secureboot/keys/ --database-path /mnt/persist/secureboot/'

# Create systemd machine-id.
systemd-machine-id-setup --root /mnt/persist/ >/dev/null 2>&1
mv /mnt/persist/etc/machine-id /mnt/persist/machine-id
rm -rf /mnt/persist/etc

# Perform system install and finish.
nixos-install --no-root-passwd --no-channel-copy --flake https://git.mkor.je/mkorje/nixos/archive/main.tar.gz#auseklis >/dev/null 2>&1

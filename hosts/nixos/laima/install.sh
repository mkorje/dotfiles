#!/run/current-system/sw/bin/bash

# This script performs the installation of the laima system.

set -euo pipefail

# Undo any previous changes. This allows me to re-run the script multiple times.
set +e
swapoff -a
umount --quiet -R /mnt
set -e

# Partition main disk.
wipefs --all --force --quiet /dev/sda
parted --script --align optimal /dev/sda \
  mklabel gpt \
  mkpart esp fat32 1MiB 513MiB \
  set 1 esp on \
  mkpart root btrfs 513MiB 100% \
  type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709

# Format and mount root partition.
mkfs.btrfs --label nixos --force --quiet /dev/sda2
mount /dev/sda2 /mnt
btrfs --quiet subvolume create /mnt/root
btrfs --quiet subvolume create /mnt/nix
btrfs --quiet subvolume create /mnt/persist
btrfs --quiet subvolume create /mnt/swap
btrfs --quiet subvolume snapshot -r /mnt/root /mnt/root-blank
umount /mnt
mount -o subvol=root,noatime,compress-force=zstd:1 /dev/sda2 /mnt
mount --mkdir -o subvol=nix,noatime,compress-force=zstd:1 /dev/sda2 /mnt/nix
mount --mkdir -o subvol=persist,noatime,compress-force=zstd:1 /dev/sda2 /mnt/persist
mount --mkdir -o subvol=swap /dev/sda2 /mnt/swap
btrfs --quiet filesystem mkswapfile --size 4g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# Format and mount boot partition.
mkfs.fat -F 32 -n boot /dev/sda1 >/dev/null 2>&1
mount --mkdir -o umask=077 /dev/sda1 /mnt/boot

# Set up machine's sops-nix secret key.
mkdir --parents /mnt/persist/sops/secrets/age
nix-shell --quiet -p age --run 'age-keygen -o /mnt/persist/sops/secrets/age/key.txt'
read -r -p 'Add this public key to sops as laima. When done, press enter to continue.'

# Create systemd machine-id.
systemd-machine-id-setup --root /mnt/persist/ >/dev/null 2>&1
mv /mnt/persist/etc/machine-id /mnt/persist/machine-id
rm -rf /mnt/persist/etc

# Perform system install and finish.
nixos-install --no-root-passwd --no-channel-copy --flake github:mkorje/dotfiles#laima >/dev/null 2>&1

echo 'Installation completed!'

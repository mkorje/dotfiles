#!/run/current-system/sw/bin/bash

# This script performs the installation of the lietuvens system.

set -euo pipefail

# Undo any previous changes. This allows me to re-run the script multiple times.
set +e
swapoff -a
umount --quiet -R /mnt
cryptsetup --batch-mode close nixos-enc
set -e

# Partition main disk.
wipefs --all --force --quiet /dev/sda
parted --script --align optimal /dev/sda \
  mklabel gpt \
  mkpart esp fat32 1MiB 1025MiB \
  set 1 esp on \
  mkpart root btrfs 1025MiB 100% \
  type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709

# Encrypt root partition.
echo '' | cryptsetup --batch-mode --hash sha512 --iter-time 10000 --label nixos-crypt luksFormat /dev/sda2
echo '' | cryptsetup --batch-mode open /dev/sda2 nixos-enc

# Format and mount root partition.
mkfs.btrfs --label nixos --force --quiet /dev/mapper/nixos-enc
mount /dev/mapper/nixos-enc /mnt
btrfs --quiet subvolume create /mnt/root
btrfs --quiet subvolume create /mnt/nix
btrfs --quiet subvolume create /mnt/persist
btrfs --quiet subvolume create /mnt/swap
btrfs --quiet subvolume create /mnt/frigate
btrfs --quiet subvolume snapshot -r /mnt/root /mnt/root-blank
umount /mnt
mount -o subvol=root,noatime,compress-force=zstd:2 /dev/mapper/nixos-enc /mnt
mount --mkdir -o subvol=nix,noatime,compress-force=zstd:2 /dev/mapper/nixos-enc /mnt/nix
mount --mkdir -o subvol=persist,noatime,compress-force=zstd:2 /dev/mapper/nixos-enc /mnt/persist
mount --mkdir -o subvol=swap /dev/mapper/nixos-enc /mnt/swap
mount --mkdir -o subvol=frigate,noatime,compress-force=zstd:2 /dev/mapper/nixos-enc /mnt/var/lib/frigate
btrfs --quiet filesystem mkswapfile --size 16g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# Format and mount boot partition.
mkfs.fat -F 32 -n boot /dev/sda1 >/dev/null 2>&1
mount --mkdir -o umask=077 /dev/sda1 /mnt/boot

# Set up machine's sops-nix secret key.
mkdir --parents /mnt/persist/sops/secrets/age
nix-shell --quiet -p age --run 'age-keygen -o /mnt/persist/sops/secrets/age/key.txt'
read -r -p 'Add this public key to sops as lietuvens. When done, press enter to continue.'

# Create secure boot keys.
nix-shell --quiet -p sbctl --run 'sbctl --quiet --disable-landlock create-keys --export /mnt/persist/secureboot/keys/ --database-path /mnt/persist/secureboot/GUID'

# Create systemd machine-id.
systemd-machine-id-setup --root /mnt/persist/ >/dev/null 2>&1
mv /mnt/persist/etc/machine-id /mnt/persist/machine-id
rm -rf /mnt/persist/etc

# Perform system install and finish.
nixos-install --no-root-passwd --no-channel-copy --flake github:mkorje/dotfiles#lietuvens >/dev/null 2>&1

echo 'Installation completed!'

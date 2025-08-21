#!/run/current-system/sw/bin/bash

# This script performs the installation of the hermes system.

set -euo pipefail

# Undo any previous changes. This allows me to re-run the script multiple times.
set +e
swapoff -a
umount --quiet -R /mnt
set -e

# Partition main disk.
wipefs --all --force --quiet /dev/vda
parted --script --align optimal /dev/vda \
  mklabel msdos \
  mkpart primary btrfs 1MiB 100% \
  set 1 boot on

# Format and mount root partition.
mkfs.btrfs --label nixos --force --quiet /dev/vda1
mount /dev/vda1 /mnt
btrfs --quiet subvolume create /mnt/root
btrfs --quiet subvolume create /mnt/nix
btrfs --quiet subvolume create /mnt/persist
btrfs --quiet subvolume create /mnt/swap
btrfs --quiet subvolume create /mnt/headscale
btrfs --quiet subvolume snapshot -r /mnt/root /mnt/root-blank
umount /mnt
mount -o subvol=root,noatime,compress-force=zstd:2 /dev/vda1 /mnt
mount --mkdir -o subvol=nix,noatime,compress-force=zstd:2 /dev/vda1 /mnt/nix
mount --mkdir -o subvol=persist,noatime,compress-force=zstd:2 /dev/vda1 /mnt/persist
mount --mkdir -o subvol=swap /dev/vda1 /mnt/swap
mount --mkdir -o subvol=headscale,noatime,compress-force=zstd:2 /dev/vda1 /mnt/var/lib/headscale
btrfs --quiet filesystem mkswapfile --size 2g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# Set up machine's sops-nix secret key.
mkdir --parents /mnt/persist/sops/secrets/age
nix-shell --quiet -p age --run 'age-keygen -o /mnt/persist/sops/secrets/age/key.txt'
read -r -p 'Add this public key to sops as hermes. When done, press enter to continue.'

# Create systemd machine-id.
systemd-machine-id-setup --root /mnt/persist/ >/dev/null 2>&1
mv /mnt/persist/etc/machine-id /mnt/persist/machine-id
rm -rf /mnt/persist/etc

# Perform system install and finish.
nixos-install --no-root-passwd --no-channel-copy --flake github:mkorje/dotfiles#hermes >/dev/null 2>&1

echo 'Installation completed!'

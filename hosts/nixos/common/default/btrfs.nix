{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.btrfs-progs ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  boot.initrd.supportedFilesystems.btrfs = true;
  boot.initrd.systemd.services."restore-root" = {
    description = "Rollback btrfs rootfs";
    wantedBy = [ "initrd.target" ];
    requires = [ "dev-disk-by\\x2dlabel-nixos.device" ];
    after = [
      "dev-disk-by\\x2dlabel-nixos.device"
      "systemd-cryptsetup@enc.service"
    ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir /tmp -p
      MNTPOINT=$(mktemp -d)
      (
        mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos "$MNTPOINT"
        trap 'umount "$MNTPOINT"' EXIT

        echo "Cleaning root subvolume"
        btrfs subvolume list -o "$MNTPOINT/root" | cut -f9 -d ' ' |
        while read -r subvolume; do
          btrfs subvolume delete "$MNTPOINT/$subvolume"
        done && btrfs subvolume delete "$MNTPOINT/root"

        echo "Restoring blank subvolume"
        btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
      )
    '';
  };
}

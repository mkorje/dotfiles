{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.btrfs-progs ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  boot.initrd = {
    enable = true;
    supportedFilesystems = {
      btrfs = true;
    };
    systemd = {
      enable = true;
      services = {
        "persist-files" = {
          description = "Hard-link persisted files from /persist";
          wantedBy = [ "initrd.target" ];
          after = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /sysroot/etc/
            ln -snfT /persist/machine-id /sysroot/etc/machine-id
          '';
        };
        "restore-root" = {
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
      };
    };
  };
}

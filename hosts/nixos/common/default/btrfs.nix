{
  services.btrfs.autoScrub.enable = true;

  boot.initrd.systemd.services."restore-root" = {
    description = "Rollback btrfs rootfs";
    wantedBy = [ "initrd.target" ];
    requires = [ "dev-disk-by\\x2dlabel-nixos.device" ];
    after = [
      "dev-disk-by\\x2dlabel-nixos.device"
      "local-fs-pre.target"
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

        btrfs subvolume show "$MNTPOINT/root-blank" >/dev/null

        if [[ -L "$MNTPOINT/root" ]]; then
          echo "root is a symlink, refusing to delete it" >&2
          exit 1
        elif [[ -e "$MNTPOINT/root" ]]; then
          echo "Cleaning root subvolume"
          btrfs subvolume delete --recursive "$MNTPOINT/root"
        fi

        echo "Restoring blank subvolume"
        btrfs subvolume snapshot "$MNTPOINT/root-blank" "$MNTPOINT/root"
      )
    '';
  };
}

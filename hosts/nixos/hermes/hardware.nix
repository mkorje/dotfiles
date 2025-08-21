{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "noatime"
      "compress-force=zstd:2"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "noatime"
      "compress-force=zstd:2"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/nixos";
    neededForBoot = true;
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "noatime"
      "compress-force=zstd:2"
    ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=swap" ];
  };

  fileSystems."/var/lib/headscale" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=headscale"
      "noatime"
      "compress-force=zstd:2"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  virtualisation.hypervGuest.enable = true;
}

{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
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
      "compress-force=zstd:1"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "noatime"
      "compress-force=zstd:1"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/nixos";
    neededForBoot = true;
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "noatime"
      "compress-force=zstd:1"
    ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=swap" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "umask=0077"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
}

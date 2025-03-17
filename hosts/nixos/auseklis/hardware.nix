{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  system.stateVersion = "24.11";

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    "nixos-enc".device = "/dev/disk/by-label/nixos-crypt";
    "data-enc".device = "/dev/disk/by-label/data-crypt";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
    "/persist" = {
      device = "/dev/disk/by-label/nixos";
      neededForBoot = true;
      fsType = "btrfs";
      options = [
        "subvol=persist"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
    "/swap" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=swap" ];
    };
    "/home" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [
        "umask=0077"
      ];
    };
    "/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [
        "subvol=data"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
    "/data/steam" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [
        "subvol=steam"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
    "/data/files" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [
        "subvol=files"
        "noatime"
        "compress-force=zstd:1"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/steam 0700 mkorje mkorje"
    "d /data/files 0700 mkorje mkorje"
  ];

  swapDevices = [ { device = "/swap/swapfile"; } ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

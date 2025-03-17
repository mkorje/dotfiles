{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  allowedUnfreePackages = [
    "brcm-firmware"
    "brcm-firmware-sonoma-zstd"
  ];

  hardware = {
    apple.touchBar.enable = true;
    apple-t2 = {
      kernelChannel = "stable";
      firmware.enable = true;
    };
  };

  system.stateVersion = "24.11";

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."nixos-enc".device = "/dev/disk/by-label/nixos-crypt";

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
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

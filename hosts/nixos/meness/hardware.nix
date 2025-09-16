{ config, ... }:

{
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "nvme"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
    "usbhid"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."nixos-enc".device = "/dev/disk/by-label/nixos-crypt";
  environment.etc.crypttab.text = ''
    data-enc /dev/disk/by-label/data-crypt /persist/luks/keys/data-crypt.key
  '';

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

  fileSystems."/var/lib/frigate" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
    options = [
      "subvol=frigate"
      "noatime"
      "compress-force=zstd:1"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "umask=0077"
    ];
  };

  boot.initrd.supportedFilesystems.zfs = true;
  boot.zfs.extraPools = [ "tank" ];
  boot.zfs.forceImportRoot = false;
  services.zfs.autoScrub.enable = true;
  environment.systemPackages = [ config.boot.zfs.package ];
  networking.hostId = "3a36c8e3";

  swapDevices = [ { device = "/swap/swapfile"; } ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
}

{ lib, ... }:

{
  imports = [
    ./hardware.nix
    ../common
    ../common/server

    ./nginx.nix
    ./headscale.nix
  ];

  boot.loader.grub.enable = lib.mkForce true;
  boot.loader.grub.device = "/dev/vda";

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Type = "ether";
    linkConfig.RequiredForOnline = "routable";
    address = [
      "139.84.200.35/23"
      "2401:c080:2000:1e23::1/64"
      "2401:c080:2000:1e23::dd/64"
    ];
    gateway = [
      "fe80::1"
      "139.84.200.1"
    ];
  };

  system.stateVersion = "25.05";
}

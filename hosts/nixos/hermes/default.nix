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
    address = [ "139.84.200.35/23" ];
    routes = [
      {
        Gateway = "139.84.200.1";
        Metric = 1000;
      }
    ];
  };

  system.stateVersion = "25.05";
}

{ ... }:

{
  imports = [
    ./hardware.nix

    ../common

    ../common/secureboot.nix
    ../common/nvidia.nix

    ../common/desktop

    ../../home-manager
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "routable";
  };
}

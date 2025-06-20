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
  systemd.network.networks."10-enp7s0" = {
    matchConfig.Name = "enp7s0";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "routable";
  };
}

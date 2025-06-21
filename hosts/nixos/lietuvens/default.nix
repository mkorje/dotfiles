{
  imports = [
    ./hardware.nix

    ../common

    ../common/secureboot.nix

    ../common/server
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-enp6s0" = {
    matchConfig.Name = "enp6s0";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.networks."10-enp5s0" = {
    matchConfig.Name = "enp5s0";
    address = [ "172.19.0.100/24" ];
    gateway = [ "172.19.0.1" ];
    linkConfig.RequiredForOnline = "routable";
  };

  system.stateVersion = "25.05";
}

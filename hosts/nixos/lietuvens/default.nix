{ ... }:

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
    address = [ "172.16.3.100/16" ];
    routes = [
      {
        Gateway = "172.16.0.1";
        Metric = 1000;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.networks."10-enp5s0" = {
    matchConfig.Name = "enp5s0";
    address = [ "172.19.0.100/24" ];
    routes = [
      {
        Gateway = "172.19.0.1";
        Metric = 1024;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  system.stateVersion = "25.05";
}

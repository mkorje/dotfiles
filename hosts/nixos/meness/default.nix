{
  imports = [
    ./hardware.nix
    ./frigate.nix
    ../common
    ../common/secureboot.nix
    ../common/nvidia.nix
    ../common/acme.nix
    ../common/server
  ];

  systemd.network.networks."10-wan" = {
    matchConfig.Type = "ether";
    linkConfig.RequiredForOnline = "routable";
    address = [
      "172.16.1.100/16"
    ];
    gateway = [
      "172.16.0.1"
    ];
  };

  system.stateVersion = "25.05";
}

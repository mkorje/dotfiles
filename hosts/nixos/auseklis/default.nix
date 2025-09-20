{ ... }:

{
  imports = [
    ./hardware.nix

    ../common

    ../common/secureboot.nix

    ../common/desktop

    ../../home-manager
  ];

  nvidia.enable = true;

  systemd.network.networks."10-wan" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "routable";
  };

  networking.nftables.ruleset = ''
    table inet excludeTraffic {
      chain excludeOutgoing {
        type route hook output priority 0; policy accept;
        ip daddr 172.16.0.0/12 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
      }
    }
  '';
}

{
  imports = [
    ./hardware.nix
    ./website.nix
    ../common
    ../common/server
    ../common/nginx.nix
    ../common/acme.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.efiSysMountPoint = "/boot";
    efi.canTouchEfiVariables = true;
  };

  systemd.network.networks."10-wan" = {
    matchConfig.Type = "ether";
    linkConfig.RequiredForOnline = "routable";
    address = [
      "5.223.68.149/32"
      "2a01:4ff:2f0:393b::1/64"
    ];
    routes = [
      { Gateway = "fe80::1"; }
      {
        Gateway = "172.31.1.1";
        GatewayOnLink = true;
      }
    ];
  };

  security.acme.certs = {
    "mkor.je".extraDomainNames = [ "*.mkor.je" ];
    "pist.is".extraDomainNames = [ "*.pist.is" ];
    "elp.is".extraDomainNames = [ "*.elp.is" ];
  };

  system.stateVersion = "25.11";
}

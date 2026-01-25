{
  imports = [
    ./hardware.nix
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
    gateway = [
      "172.31.1.1"
      "fe80::1"
    ];
  };

  # services.nginx.virtualHosts."${domain}" = {
  #   default = true;
  #   forceSSL = true;
  #   useACMEHost = domain;
  #   quic = true;
  #   kTLS = true;
  #   listenAddresses = [
  #     "139.84.200.35"
  #     "[2401:c080:2000:1e23::1]"
  #   ];
  #   locations."/" = {
  #     return = "200 '<html><body>It works</body></html>'";
  #     extraConfig = ''
  #       default_type text/html;
  #     '';
  #   };
  #   locations."/robots.txt" = {
  #     extraConfig = ''
  #       rewrite ^/(.*)  $1;
  #       return 200 "User-agent: *\nDisallow: /";
  #     '';
  #   };
  # };

  security.acme.certs = {
    "mkor.je".extraDomainNames = [ "*.mkor.je" ];
    "pist.is".extraDomainNames = [ "*.pist.is" ];
    "elp.is".extraDomainNames = [ "*.elp.is" ];
  };

  system.stateVersion = "25.11";
}

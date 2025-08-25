{
  lib,
  config,
  domain,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../common
    ../common/server
    ../common/nginx.nix

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

  services.nginx.virtualHosts."${domain}" = {
    default = true;
    forceSSL = true;
    useACMEHost = domain;
    quic = true;
    kTLS = true;
    listenAddresses = [
      "139.84.200.35"
      "[2401:c080:2000:1e23::1]"
    ];
    locations."/" = {
      return = "200 '<html><body>It works</body></html>'";
      extraConfig = ''
        default_type text/html;
      '';
    };
    locations."/robots.txt" = {
      extraConfig = ''
        rewrite ^/(.*)  $1;
        return 200 "User-agent: *\nDisallow: /";
      '';
    };
  };

  sops.secrets."hermes/acme/hetzner/apiKey" = { };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@mkor.je";
      dnsProvider = "hetzner";
      credentialFiles."HETZNER_API_KEY_FILE" = config.sops.secrets."hermes/acme/hetzner/apiKey".path;
      keyType = "ec384";
      inherit (config.services.nginx) group;
    };
    certs = {
      "mkor.je".extraDomainNames = [ "*.mkor.je" ];
      "pist.is".extraDomainNames = [ "*.pist.is" ];
      "elp.is".extraDomainNames = [ "*.elp.is" ];
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/acme"
  ];

  system.stateVersion = "25.05";
}

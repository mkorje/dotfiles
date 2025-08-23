{
  domain,
  config,
  pkgs,
  ...
}:

{
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;

    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;

    virtualHosts."${domain}" = {
      default = true;
      forceSSL = true;
      useACMEHost = domain;
      quic = true;
      kTLS = true;
      locations."/" = {
        return = "200 '<html><body>It works</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  sops.secrets."hermes/acme/hetzner/apiKey" = { };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@mkor.je";
      dnsProvider = "hetzner";
      credentialFiles = {
        "HETZNER_API_KEY_FILE" = config.sops.secrets."hermes/acme/hetzner/apiKey".path;
      };
      keyType = "ec384";
      inherit (config.services.nginx) group;
    };
    certs = {
      "mkor.je".extraDomainNames = [ "*.mkor.je" ];
      "pist.is".extraDomainNames = [ "*.pist.is" ];
      "elp.is".extraDomainNames = [ "*.elp.is" ];
    };
  };

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/acme"
    ];
  };
}

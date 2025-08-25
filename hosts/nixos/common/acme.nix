{ config, ... }:

{
  sops.secrets."acme/hetzner/apiKey" = { };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@mkor.je";
      dnsProvider = "hetzner";
      credentialFiles."HETZNER_API_KEY_FILE" = config.sops.secrets."acme/hetzner/apiKey".path;
      inherit (config.services.nginx) group;
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/acme"
  ];
}

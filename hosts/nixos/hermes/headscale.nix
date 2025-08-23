{ domain, config, ... }:

{
  services.headscale = {
    enable = true;
    port = 8085;
    settings = {
      server_url = "https://tailscale.${domain}";
      dns.base_domain = "tailnet.${domain}";
      dns.nameservers.global = config.networking.nameservers;
    };
  };

  services.nginx.virtualHosts = {
    "tailscale.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      quic = true;
      kTLS = true;
      locations."/" = {
        proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}

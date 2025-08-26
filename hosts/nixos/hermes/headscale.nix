{ domain, config, ... }:

{
  services.headscale = {
    enable = true;
    port = 8085;
    settings = {
      server_url = "https://tailscale.${domain}";
      dns.base_domain = "tailnet.${domain}";
      dns.nameservers.global = config.networking.nameservers;
      dns.nameservers.split."pist.is" = [ "172.16.0.1" ];
      derp.server = {
        enabled = true;
        ipv4 = "139.84.200.35";
        ipv6 = "2401:c080:2000:1e23::dd";
        stun_listen_addr = "0.0.0.0:3478";
      };
    };
  };

  # Derp server port
  networking.firewall.allowedUDPPorts = [ 3478 ];

  services.nginx.virtualHosts = {
    "tailscale.${domain}" = {
      forceSSL = true;
      useACMEHost = domain;
      quic = true;
      kTLS = true;
      listenAddresses = [
        "139.84.200.35"
        "[2401:c080:2000:1e23::dd]"
      ];
      locations."/" = {
        proxyPass = "http://${config.services.headscale.address}:${toString config.services.headscale.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}

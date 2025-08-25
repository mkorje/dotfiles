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
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    experimentalZstdSettings = true;

    # https://ssl-config.mozilla.org/#server=nginx&config=modern&ocsp=false
    sslProtocols = "TLSv1.3";
    commonHttpConfig = ''
      ssl_ecdh_curve X25519:prime256v1:secp384r1;
      ssl_prefer_server_ciphers off;
    '';

    appendHttpConfig = ''
      map $scheme $hsts_header {
        https "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header always;
      add_header Content-Security-Policy "default-src 'none'; base-uri 'none'; frame-ancestors 'none'; form-action 'none'; trusted-types 'none'; require-trusted-types-for 'script'" always;
      add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), autoplay=(), battery=(), camera=(), cross-origin-isolated=(), display-capture=(), document-domain=(), encrypted-media=(), execution-while-not-rendered=(), execution-while-out-of-viewport=(), fullscreen=(), geolocation=(), gyroscope=(), keyboard-map=(), magnetometer=(), microphone=(), midi=(), navigation-override=(), payment=(), picture-in-picture=(), publickey-credentials-get=(), screen-wake-lock=(), sync-xhr=(), usb=(), web-share=(), xr-spatial-tracking=()" always;
      add_header Referrer-Policy no-referrer;
      add_header X-Frame-Options DENY always;
      add_header X-Content-Type-Options nosniff always;
      add_header Cross-Origin-Resource-Policy same-origin always;
      add_header Cross-Origin-Embedder-Policy require-corp always;
      add_header Cross-Origin-Opener-Policy same-origin always;
    '';

    virtualHosts."${domain}" = {
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

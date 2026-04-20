{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  user = "website-mkor-je";
  home = "/var/lib/${user}";
  service = "website-mkor-je-deploy";
  rootDir = "/var/www";
  root = "${rootDir}/mkor.je";
  secretEnvVar = "deploy-secret";
  triggerDir = "/run/${service}";
  trigger = "${triggerDir}/trigger";
in
{
  users.users.${user} = {
    isSystemUser = true;
    group = user;
    inherit home;
    createHome = true;
  };
  users.groups.${user} = { };

  environment.persistence."/persist".directories = [
    rootDir
    {
      directory = home;
      inherit user;
      group = user;
      mode = "0755";
    }
  ];

  systemd.tmpfiles.rules = [
    "d ${rootDir} 0775 root ${user} -"
    "d ${triggerDir} 0755 ${config.services.webhook.user} ${config.services.webhook.group} -"
  ];

  services.nginx.appendHttpConfig = ''
    limit_req_zone $binary_remote_addr zone=mkor_je_hooks:10m rate=1r/s;
  '';

  services.nginx.virtualHosts."mkor.je" = {
    default = true;
    onlySSL = true;
    useACMEHost = "mkor.je";
    quic = true;
    kTLS = true;
    listenAddresses = [
      "5.223.68.149"
      "[2a01:4ff:2f0:393b::1]"
    ];

    inherit root;

    locations."/" = {
      tryFiles = "$uri $uri.html $uri/index.html =404";
    };

    locations."/hooks/" = {
      proxyPass = "http://${config.services.webhook.ip}:${toString config.services.webhook.port}";
      extraConfig = ''
        limit_except POST { deny all; }
        limit_req zone=mkor_je_hooks burst=5 nodelay;
        client_max_body_size 1m;
        client_body_timeout 10s;
      '';
    };

    locations."/robots.txt" = {
      extraConfig = ''
        rewrite ^/(.*)  $1;
        return 200 "User-agent: *\nDisallow: /";
      '';
    };
  };

  systemd = {
    services.${service} = {
      path = [
        pkgs.nix
        pkgs.git
        pkgs.coreutils
      ];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        Group = user;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ReadWritePaths = [
          home
          rootDir
        ];
        ExecStart = ''
          ${pkgs.nix}/bin/nix \
            --extra-experimental-features "nix-command flakes" \
            build --refresh --out-link ${root} github:mkorje/me
        '';
      };
    };
    paths.${service} = {
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = trigger;
    };
  };

  sops.secrets."website/hooks/deploy" = { };
  systemd.services.webhook.serviceConfig = {
    LoadCredential = [
      "${secretEnvVar}:${config.sops.secrets."website/hooks/deploy".path}"
    ];
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    PrivateDevices = true;
    PrivateUsers = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectKernelLogs = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectProc = "invisible";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service"
      "~@privileged"
      "~@resources"
    ];
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    ReadWritePaths = [ triggerDir ];
    UMask = "0077";
  };

  services.webhook = {
    enable = true;
    package = pkgs-unstable.webhook;
    ip = "127.0.0.1";
    hooksTemplated.deploy = ''
      {
        "id": "deploy",
        "execute-command": "${pkgs.coreutils}/bin/touch",
        "pass-arguments-to-command": [
          { "source": "string", "name": "${trigger}" }
        ],
        "trigger-rule": {
          "and": [
            {
              "match": {
                "type": "payload-hmac-sha256",
                "secret": "{{ credential "${secretEnvVar}" | js }}",
                "parameter": { "source": "header", "name": "X-Hub-Signature-256" }
              }
            },
            {
              "match": {
                "type": "value",
                "value": "refs/heads/main",
                "parameter": { "source": "payload", "name": "ref" }
              }
            }
          ]
        }
      }
    '';
  };
}

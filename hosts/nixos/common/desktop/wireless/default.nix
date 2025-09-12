{ config, pkgs, ... }:

{
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        AddressRandomization = "network";
      };
    };
  };

  sops.secrets = {
    "networking/wireless/Aether/passphrase".sopsFile = ./secrets.yaml;
    "networking/wireless/TeamSAM/passphrase".sopsFile = ./secrets.yaml;
    "networking/wireless/eduroam/identity".sopsFile = ./secrets.yaml;
    "networking/wireless/eduroam/password".sopsFile = ./secrets.yaml;
  };

  # https://man.archlinux.org/man/iwd.network.5
  sops.templates = {
    "Aether.psk".content = ''
      [Security]
      Passphrase=${config.sops.placeholder."networking/wireless/Aether/passphrase"}
    '';

    "TeamSAM.psk".content = ''
      [Security]
      Passphrase=${config.sops.placeholder."networking/wireless/TeamSAM/passphrase"}
    '';

    "eduroam.8021x".content = ''
      [Security]
      EAP-Method=PEAP
      EAP-Identity=anonymous@student.unimelb.edu.au
      EAP-PEAP-Phase2-Method=MSCHAPV2
      EAP-PEAP-Phase2-Identity=${config.sops.placeholder."networking/wireless/eduroam/identity"}
      EAP-PEAP-Phase2-Password=${config.sops.placeholder."networking/wireless/eduroam/password"}
    '';
  };

  systemd.services.iwd.preStart = ''
    ln -sf ${config.sops.templates."Aether.psk".path} /var/lib/iwd/Aether.psk
    ln -sf ${config.sops.templates."TeamSAM.psk".path} /var/lib/iwd/TeamSAM.psk
    ln -sf ${config.sops.templates."eduroam.8021x".path} /var/lib/iwd/eduroam.8021x
  '';

  services.tailscale = {
    enable = true;
    package = pkgs.tailscale.overrideAttrs { doCheck = false; };
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--login-server https://tailscale.pist.is" ];
  };

  environment.persistence."/persist".directories = [
    "/var/lib/tailscale"
  ];

  networking.nftables.ruleset = ''
    table inet excludeTraffic {
      chain excludeOutgoing {
        type route hook output priority 0; policy accept;
        ip daddr 172.16.0.0/16 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
        ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
        ip6 daddr fd7a:115c:a1e0::/48 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
      }
    }
  '';
}

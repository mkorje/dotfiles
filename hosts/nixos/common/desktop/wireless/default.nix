{ config, ... }:

{
  networking.useDHCP = false;
  systemd.network.enable = false;

  # wireless networking - iwd
  networking.wireless.iwd = {
    enable = true;
    # https://man.archlinux.org/man/iwd.config.5
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        AddressRandomization = "network";
      };
      Settings = {
        AutoConnect = true;
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
}

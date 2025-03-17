{ config, pkgs, ... }:

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
    "networking/wireless/home/passphrase".sopsFile = ./secrets.yaml;
    "networking/wireless/mordy/passphrase".sopsFile = ./secrets.yaml;
    "networking/wireless/eduroam/identity".sopsFile = ./secrets.yaml;
    "networking/wireless/eduroam/password".sopsFile = ./secrets.yaml;
  };

  # https://man.archlinux.org/man/iwd.network.5
  sops.templates = {
    "Telstra122A4F.psk".content = ''
      [Security]
      Passphrase=${config.sops.placeholder."networking/wireless/home/passphrase"}
    '';

    "TeamSAM.psk".content = ''
      [Security]
      Passphrase=${config.sops.placeholder."networking/wireless/mordy/passphrase"}
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
    ln -sf ${config.sops.templates."Telstra122A4F.psk".path} /var/lib/iwd/Telstra122A4F.psk
    ln -sf ${config.sops.templates."TeamSAM.psk".path} /var/lib/iwd/TeamSAM.psk
    ln -sf ${config.sops.templates."eduroam.8021x".path} /var/lib/iwd/eduroam.8021x
  '';

  # dns resolver - systemd-resolved
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
  services.resolved = {
    enable = true;
    domains = [ "~." ];
  };

  # vpn
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
    enableExcludeWrapper = false;
  };

  # bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };
  services.blueman.enable = true;
}

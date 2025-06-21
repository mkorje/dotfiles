{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix

    ../common

    ../common/secureboot.nix

    ../common/server
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];

  systemd.network.enable = true;
  systemd.network.networks."10-enp6s0" = {
    matchConfig.Name = "enp6s0";
    address = [ "172.16.3.100/16" ];
    gateway = [ "172.16.0.1" ];
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.networks."10-enp5s0" = {
    matchConfig.Name = "enp5s0";
    address = [ "172.19.0.100/24" ];
    gateway = [ "172.19.0.1" ];
    linkConfig.RequiredForOnline = "routable";
  };

  environment.systemPackages = with pkgs; [ pciutils ];

  sops.secrets."frigate/cameras/front/password".owner = "frigate";
  sops.templates."frigate/authentication.env" = {
    owner = "frigate";
    content = ''
      FRONT_PASSWORD=${config.sops.placeholder."frigate/cameras/front/password"}
    '';
  };

  systemd.services.frigate.serviceConfig.EnvironmentFile =
    config.sops.templates."frigate/authentication.env".path;

  services.frigate.enable = true;
  services.frigate.hostname = "frigate.mkor.je";
  services.frigate.settings = {
    detectors = {
      coral = {
        type = "edgetpu";
        device = "pci";
      };
    };
  };

  services.frigate.settings.cameras.front.ffmpeg.inputs = [
    {
      path = "rtsp://stream:{FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=2";
      roles = [ "detect" ];
    }
    {
      path = "rtsp://stream:{FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=0";
      roles = [ "record" ];
    }
  ];

  system.stateVersion = "25.05";
}

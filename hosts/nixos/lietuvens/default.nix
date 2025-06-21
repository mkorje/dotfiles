{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix

    ../common

    ../common/secureboot.nix

    ../common/server
  ];

  nixpkgs.overlays = [
    inputs.tensorflow.overlays.default
  ];

  networking.firewall.allowedTCPPorts = [ 80 ];

  systemd.network.enable = true;
  systemd.network.networks."10-enp6s0" = {
    matchConfig.Name = "enp6s0";
    address = [ "172.16.3.100/16" ];
    routes = [
      {
        Gateway = "172.16.0.1";
        Metric = 1000;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  systemd.network.networks."10-enp5s0" = {
    matchConfig.Name = "enp5s0";
    address = [ "172.19.0.100/24" ];
    routes = [
      {
        Gateway = "172.19.0.1";
        Metric = 1024;
      }
    ];
    linkConfig.RequiredForOnline = "routable";
  };

  sops.secrets."frigate/cameras/front/password".owner = "frigate";
  sops.secrets."frigate/cameras/back/password".owner = "frigate";
  sops.secrets."frigate/cameras/door/password".owner = "frigate";
  sops.secrets."frigate/cameras/side/password".owner = "frigate";
  sops.templates."frigate/authentication.env" = {
    owner = "frigate";
    content = ''
      FRIGATE_FRONT_PASSWORD=${config.sops.placeholder."frigate/cameras/front/password"}
      FRIGATE_BACK_PASSWORD=${config.sops.placeholder."frigate/cameras/back/password"}
      FRIGATE_DOOR_PASSWORD=${config.sops.placeholder."frigate/cameras/door/password"}
      FRIGATE_SIDE_PASSWORD=${config.sops.placeholder."frigate/cameras/side/password"}
    '';
  };

  systemd.services.frigate.serviceConfig.EnvironmentFile =
    config.sops.templates."frigate/authentication.env".path;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.frigate.enable = true;
  services.frigate.hostname = "frigate.mkor.je";
  services.frigate.vaapiDriver = "iHD";
  services.frigate.settings = {
    ffmpeg.hwaccel_args = "preset-vaapi";
    detectors = {
      coral1 = {
        type = "edgetpu";
        device = "pci:0";
      };
      coral2 = {
        type = "edgetpu";
        device = "pci:1";
      };
    };
    record = {
      enabled = true;
      retain = {
        days = 3;
        mode = "all";
      };
    };
    camera_groups.Front = {
      order = 1;
      icon = "LuDoorOpen";
      cameras = [
        "front"
        "door"
      ];
    };
    camera_groups.Back = {
      order = 2;
      icon = "LuFlower2";
      cameras = "back";
    };
    camera_groups.Side = {
      order = 3;
      icon = "LuTrash2";
      cameras = "side";
    };
  };

  services.frigate.settings.cameras.front.ffmpeg.inputs = [
    {
      path = "rtsp://stream:{FRIGATE_FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=2";
      roles = [ "detect" ];
    }
    {
      path = "rtsp://stream:{FRIGATE_FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=0";
      roles = [ "record" ];
    }
  ];

  services.frigate.settings.cameras.back.ffmpeg.inputs = [
    {
      path = "rtsp://stream:{FRIGATE_BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=2";
      roles = [ "detect" ];
    }
    {
      path = "rtsp://stream:{FRIGATE_BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=0";
      roles = [ "record" ];
    }
  ];

  services.frigate.settings.cameras.door.ffmpeg.inputs = [
    {
      path = "rtsp://stream:{FRIGATE_DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=1";
      roles = [ "detect" ];
    }
    {
      path = "rtsp://stream:{FRIGATE_DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=0";
      roles = [ "record" ];
    }
  ];

  services.frigate.settings.cameras.side.ffmpeg.inputs = [
    {
      path = "rtsp://stream:{FRIGATE_SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=1";
      roles = [ "detect" ];
    }
    {
      path = "rtsp://stream:{FRIGATE_SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=0";
      roles = [ "record" ];
    }
  ];

  system.stateVersion = "25.05";
}

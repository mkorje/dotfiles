{
  config,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    inputs.frigate.overlays.default
  ];

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

  services.frigate.enable = true;
  services.frigate.hostname = "frigate.mkor.je";

  services.frigate.vaapiDriver = "iHD";
  services.frigate.settings.ffmpeg = {
    hwaccel_args = "preset-vaapi";
    output_args.record = "preset-record-generic-audio-copy";
  };

  services.frigate.settings.ui = {
    timezone = "Australia/Melbourne";
    time_format = "12hour";
    date_style = "long";
    time_style = "medium";
  };

  services.frigate.settings.detectors = {
    coral1 = {
      type = "edgetpu";
      device = "pci:0";
    };
    coral2 = {
      type = "edgetpu";
      device = "pci:1";
    };
  };

  services.frigate.settings.snapshots.enabled = true;
  services.frigate.settings.record = {
    enabled = true;
    retain = {
      days = 3;
      mode = "motion";
    };
    alerts.retain = {
      days = 10;
      mode = "motion";
    };
    detections.retain = {
      days = 10;
      mode = "motion";
    };
  };

  services.frigate.settings.camera_groups = {
    Front = {
      order = 1;
      icon = "LuDoorOpen";
      cameras = [
        "front"
        "door"
      ];
    };
    Back = {
      order = 2;
      icon = "LuFlower2";
      cameras = "back";
    };
    Side = {
      order = 3;
      icon = "LuTrash2";
      cameras = "side";
    };
  };

  services.frigate.settings.go2rtc.streams = {
    front = [
      "rtsp://stream:{FRIGATE_FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=0"
    ];
    back = [
      "rtsp://stream:{FRIGATE_BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=0"
    ];
    door = [
      "rtsp://stream:{FRIGATE_DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=0"
    ];
    side = [
      "rtsp://stream:{FRIGATE_SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=0"
    ];
  };

  services.frigate.settings.cameras.front = {
    webui_url = "http://172.19.0.110";
    ffmpeg.inputs = [
      {
        path = "rtsp://stream:{FRIGATE_FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=2";
        roles = [ "detect" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/front";
        input_args = "preset-rtsp-restream-low-latency";
        roles = [ "record" ];
      }
    ];
    objects.filters.person.mask = "0.02,0.34,0.14,0.34,0.14,0.57,0.02,0.57";
  };

  services.frigate.settings.cameras.back = {
    webui_url = "http://172.19.0.120";
    ffmpeg.inputs = [
      {
        path = "rtsp://stream:{FRIGATE_BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=2";
        roles = [ "detect" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/back";
        input_args = "preset-rtsp-restream-low-latency";
        roles = [ "record" ];
      }
    ];
  };

  services.frigate.settings.cameras.door = {
    webui_url = "http://172.19.0.130";
    ffmpeg.inputs = [
      {
        path = "rtsp://stream:{FRIGATE_DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=1";
        roles = [ "detect" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/door";
        input_args = "preset-rtsp-restream-low-latency";
        roles = [ "record" ];
      }
    ];
  };

  services.frigate.settings.cameras.side = {
    webui_url = "http://172.19.0.140";
    ffmpeg.inputs = [
      {
        path = "rtsp://stream:{FRIGATE_SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=1";
        roles = [ "detect" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/side";
        input_args = "preset-rtsp-restream-low-latency";
        roles = [ "record" ];
      }
    ];
  };

  services.go2rtc.enable = true;
  services.go2rtc.settings.streams = {
    front = "rtsp://stream:\${FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=0";
    back = "rtsp://stream:\${BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=0";
    door = "rtsp://stream:\${DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=0";
    side = "rtsp://stream:\${SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=0";
  };
  systemd.services.go2rtc.serviceConfig.LoadCredential = [
    "FRONT_PASSWORD:${config.sops.secrets."frigate/cameras/front/password".path}"
    "BACK_PASSWORD:${config.sops.secrets."frigate/cameras/back/password".path}"
    "DOOR_PASSWORD:${config.sops.secrets."frigate/cameras/door/password".path}"
    "SIDE_PASSWORD:${config.sops.secrets."frigate/cameras/side/password".path}"
  ];
}

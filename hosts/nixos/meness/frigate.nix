{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:

let
  pkgs-frigate = import inputs.nixpkgs-frigate {
    inherit (pkgs) system;
  };
in
{
  services.frigate.enable = true;
  services.frigate.package = pkgs-frigate.frigate;
  services.frigate.hostname = "frigate.pist.is";
  services.frigate.settings.telemetry.version_check = false;

  systemd.services.frigate.environment.LD_LIBRARY_PATH = lib.mkForce (
    lib.makeLibraryPath (
      with pkgs;
      [
        libedgetpu
        addDriverRunpath.driverLink
      ]
    )
  );
  services.frigate.vaapiDriver = "nvidia";
  services.frigate.settings.ffmpeg = {
    hwaccel_args = "preset-nvidia";
    input_args = "preset-rtsp-restream-low-latency";
    # This is `preset-record-generic-audio-copy` with `-copyinkf` added. May be
    # due to https://trac.ffmpeg.org/ticket/11531, should be fixed in the next
    # version (current version is 7.1.1).
    output_args.record = "-f segment -segment_time 10 -segment_format mp4 -reset_timestamps 1 -strftime 1 -c copy -copyinkf";
  };

  services.frigate.settings.ui = {
    timezone = "Australia/Melbourne";
    time_format = "12hour";
    date_style = "long";
    time_style = "medium";
  };

  services.frigate.settings.motion.enabled = true;
  services.frigate.settings.face_recognition.enabled = true;
  services.frigate.settings.face_recognition.model_size = "large";
  services.frigate.settings.detect.enabled = true;
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

  sops.secrets."frigate/genai/gemini/apiKey".owner = "frigate";
  sops.templates."frigate/secrets.env" = {
    owner = "frigate";
    content = ''
      FRIGATE_GENAI_API_KEY=${config.sops.placeholder."frigate/genai/gemini/apiKey"}
    '';
  };

  services.frigate.checkConfig = false;
  systemd.services.frigate.serviceConfig.EnvironmentFile =
    config.sops.templates."frigate/secrets.env".path;

  services.frigate.settings.genai = {
    enabled = true;
    provider = "gemini";
    api_key = "{FRIGATE_GENAI_API_KEY}";
    model = "gemini-2.5-flash";
  };

  services.frigate.settings.birdseye.enabled = false;
  services.frigate.settings.audio.enabled = true;
  services.frigate.settings.snapshots.enabled = true;
  services.frigate.settings.record = {
    enabled = true;
    retain = {
      days = 3;
      mode = "motion";
    };
    alerts.retain.days = 10;
    detections.retain.days = 10;
  };

  services.frigate.settings.go2rtc.streams = {
    front = [ ];
    back = [ ];
    door = [ ];
    side = [ ];
    front_sub = [ ];
    back_sub = [ ];
    door_sub = [ ];
    side_sub = [ ];
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

  services.frigate.settings.cameras.front = {
    webui_url = "http://172.19.0.110";
    ffmpeg.inputs = [
      {
        path = "rtsp://127.0.0.1:8554/front";
        roles = [ "record" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/front_sub";
        roles = [
          "audio"
          "detect"
        ];
      }
    ];
  };

  services.frigate.settings.cameras.back = {
    webui_url = "http://172.19.0.120";
    ffmpeg.inputs = [
      {
        path = "rtsp://127.0.0.1:8554/back";
        roles = [ "record" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/back_sub";
        roles = [
          "audio"
          "detect"
        ];
      }
    ];
  };

  services.frigate.settings.cameras.door = {
    webui_url = "http://172.19.0.130";
    ffmpeg.inputs = [
      {
        path = "rtsp://127.0.0.1:8554/door";
        roles = [ "record" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/door_sub";
        roles = [
          "audio"
          "detect"
        ];
      }
    ];
  };

  services.frigate.settings.cameras.side = {
    webui_url = "http://172.19.0.140";
    ffmpeg.inputs = [
      {
        path = "rtsp://127.0.0.1:8554/side";
        roles = [ "record" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/side_sub";
        roles = [
          "audio"
          "detect"
        ];
      }
    ];
  };

  services.go2rtc.enable = true;
  services.go2rtc.settings.streams = {
    front = "rtsp://stream:\${FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=0";
    back = "rtsp://stream:\${BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=0";
    door = "rtsp://stream:\${DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=0";
    side = "rtsp://stream:\${SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=0";
    front_sub = "rtsp://stream:\${FRONT_PASSWORD}@172.19.0.110/cam/realmonitor?channel=1&subtype=2";
    back_sub = "rtsp://stream:\${BACK_PASSWORD}@172.19.0.120/cam/realmonitor?channel=1&subtype=2";
    door_sub = "rtsp://stream:\${DOOR_PASSWORD}@172.19.0.130/cam/realmonitor?channel=1&subtype=1";
    side_sub = "rtsp://stream:\${SIDE_PASSWORD}@172.19.0.140/cam/realmonitor?channel=1&subtype=1";
  };
  systemd.services.go2rtc.serviceConfig.LoadCredential = [
    "FRONT_PASSWORD:${config.sops.secrets."frigate/cameras/front/password".path}"
    "BACK_PASSWORD:${config.sops.secrets."frigate/cameras/back/password".path}"
    "DOOR_PASSWORD:${config.sops.secrets."frigate/cameras/door/password".path}"
    "SIDE_PASSWORD:${config.sops.secrets."frigate/cameras/side/password".path}"
  ];
  sops.secrets."frigate/cameras/front/password".owner = "frigate";
  sops.secrets."frigate/cameras/back/password".owner = "frigate";
  sops.secrets."frigate/cameras/door/password".owner = "frigate";
  sops.secrets."frigate/cameras/side/password".owner = "frigate";

  services.nginx.virtualHosts."${config.services.frigate.hostname}" = {
    default = true;
    forceSSL = true;
    enableACME = true;
    acmeRoot = null;
    kTLS = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    1984
  ];
}

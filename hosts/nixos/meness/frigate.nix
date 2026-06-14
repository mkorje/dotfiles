{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mapAttrs
    mapAttrs'
    mapAttrsToList
    nameValuePair
    concatMapAttrs
    toUpper
    ;

  cameras = {
    front = {
      ip = "172.19.0.110";
      subSubtype = 2;
    };
    back = {
      ip = "172.19.0.120";
      subSubtype = 2;
    };
    door = {
      ip = "172.19.0.130";
      subSubtype = 1;
    };
    side = {
      ip = "172.19.0.140";
      subSubtype = 1;
    };
  };

  passwordEnv = name: "${toUpper name}_PASSWORD";
  mkRtsp =
    ip: name: subtype:
    "rtsp://stream:\${${passwordEnv name}}@${ip}/cam/realmonitor?channel=1&subtype=${toString subtype}";
in
{
  services.frigate.enable = true;
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

  # sops.secrets."frigate/genai/gemini/apiKey".owner = "frigate";
  # sops.templates."frigate/secrets.env" = {
  #   owner = "frigate";
  #   content = ''
  #     FRIGATE_GENAI_API_KEY=${config.sops.placeholder."frigate/genai/gemini/apiKey"}
  #   '';
  # };
  # services.frigate.checkConfig = false;
  # systemd.services.frigate.serviceConfig.EnvironmentFile =
  #   config.sops.templates."frigate/secrets.env".path;

  services.frigate.settings.genai = {
    enabled = true;
    provider = "ollama";
    base_url = "http://localhost:11434";
    model = "gemma3:4b";
    object_prompts.person = "Examine the person in these images from the {camera} security camera of a house. What are they doing and what might their actions suggest about their intent (e.g., delivering something, approaching a door, leaving an area, standing still)? If they are carrying or interacting with a package, include details about its source or destination. Do not describe the surroundings or static details. Keep your response direct and brief. It should be at most a couple of sentences and you should not add any introduction or conclusion.";
  };

  services.ollama = {
    enable = true;
    loadModels = [ "gemma3:4b" ];
  };

  services.frigate.settings.semantic_search = {
    enabled = true;
    model = "jinav2";
    model_size = "large";
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

  services.frigate.settings.go2rtc.streams = concatMapAttrs (name: _: {
    ${name} = [ ];
    "${name}_sub" = [ ];
  }) cameras;

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

  services.frigate.settings.cameras = mapAttrs (name: cam: {
    webui_url = "http://${cam.ip}";
    ffmpeg.inputs = [
      {
        path = "rtsp://127.0.0.1:8554/${name}";
        roles = [ "record" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/${name}_sub";
        roles = [
          "audio"
          "detect"
        ];
      }
    ];
  }) cameras;

  services.go2rtc.enable = true;
  services.go2rtc.settings.streams = concatMapAttrs (name: cam: {
    ${name} = mkRtsp cam.ip name 0;
    "${name}_sub" = mkRtsp cam.ip name cam.subSubtype;
  }) cameras;
  systemd.services.go2rtc.serviceConfig.LoadCredential = mapAttrsToList (
    name: _: "${passwordEnv name}:${config.sops.secrets."frigate/cameras/${name}/password".path}"
  ) cameras;
  sops.secrets = mapAttrs' (
    name: _: nameValuePair "frigate/cameras/${name}/password" { owner = "frigate"; }
  ) cameras;

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

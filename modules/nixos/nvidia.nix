{
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.nvidia;
in
{
  options.nvidia = {
    enable = mkEnableOption "NVIDIA";
    headless = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Whether the host is headless.";
    };
    cuda = mkEnableOption "CUDA";
  };

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true;
    hardware.nvidia.nvidiaSettings = !cfg.headless;

    environment.sessionVariables = {
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    allowedUnfreePackages = [
      "nvidia-x11"
    ]
    ++ optionals (!cfg.headless) [ "nvidia-settings" ];

    nixpkgs.config.cudaSupport = cfg.cuda;
    services.ollama.acceleration = mkIf cfg.cuda "cuda";
  };
}

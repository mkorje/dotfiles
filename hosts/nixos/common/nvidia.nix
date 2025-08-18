{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  environment.sessionVariables = {
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  allowedUnfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
  ];
}

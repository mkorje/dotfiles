{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  nixpkgs.config.cudaSupport = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  allowedUnfreePackages = [
    # Nvidia
    "nvidia-x11"
    "nvidia-settings"

    # CUDA
    "cuda_cudart"
    "cuda_nvcc"
    "cuda_nvrtc"
    "cuda_nvml_dev"
    "cuda_cccl"
    "libcublas"
    "libcurand"
    "libcusparse"
    "libnvjitlink"
    "libcufft"
    "cudnn"
  ];
}

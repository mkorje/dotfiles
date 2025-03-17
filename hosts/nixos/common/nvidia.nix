{ config, pkgs, ... }:

{
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  allowedUnfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
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
    "discord"
  ];

  environment.systemPackages = [ pkgs.discord ];

  nixpkgs.config.cudaSupport = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}

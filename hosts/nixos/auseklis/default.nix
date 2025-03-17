{ ... }:

{
  imports = [
    ./hardware.nix

    ../common

    ../common/secureboot.nix
    ../common/nvidia.nix

    ../common/desktop

    ../../home-manager
  ];
}

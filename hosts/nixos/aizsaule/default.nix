{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix

    ../common

    ../common/desktop
    ../common/desktop/wireless

    ../../home-manager
  ];

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.efiSysMountPoint = "/boot";
    efi.canTouchEfiVariables = true;
  };
}

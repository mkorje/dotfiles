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

  systemd.network.networks."10-wan" = {
    matchConfig.Type = "wlan";
    networkConfig = {
      DHCP = "yes";
      UseDomains = "no";
      Domains = [ "~." ];
      IgnoreCarrierLoss = "3s";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.efiSysMountPoint = "/boot";
    efi.canTouchEfiVariables = true;
  };
}

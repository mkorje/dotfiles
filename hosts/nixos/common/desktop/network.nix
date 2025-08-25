{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
    enableExcludeWrapper = false;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    extraUpFlags = [ "--login-server https://tailscale.pist.is" ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
    "/etc/mullvad-vpn"
    "/var/lib/tailscale"
  ];
}

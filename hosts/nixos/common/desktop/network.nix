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
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
    "/var/lib/tailscale"
    "/etc/mullvad-vpn"
  ];
}

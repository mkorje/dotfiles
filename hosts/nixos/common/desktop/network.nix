{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
    enableExcludeWrapper = false;
  };

  services.tailscale = {
    useRoutingFeatures = "client";
    disableUpstreamLogging = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
    "/var/lib/tailscale"
    "/etc/mullvad-vpn"
  ];
}

{
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
    enableExcludeWrapper = false;
  };

  services.tailscale = {
    enable = true;
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

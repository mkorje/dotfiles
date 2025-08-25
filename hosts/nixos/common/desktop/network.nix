{ pkgs, ... }:

{
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
    enableExcludeWrapper = false;
  };

  networking.nftables.ruleset = ''
    table inet excludeTraffic {
      chain excludeOutgoing {
        type route hook output priority 0; policy accept;
        ip daddr 172.16.0.0/12 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
      }
    }
  '';

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
    "/etc/mullvad-vpn"
  ];
}

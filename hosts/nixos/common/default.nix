{ pkgs, ... }:

{
  imports = [
    ./default/btrfs.nix
    ./default/impermanence.nix
    ./default/nix.nix
    ./default/nixpkgs-issue-55674.nix
    ./default/sops.nix
  ];

  services.userborn.enable = true;
  users.mutableUsers = false;
  users.users."root".hashedPassword = "!";

  boot = {
    initrd.systemd.enable = true;
    enableContainers = false;
    loader.grub.enable = false;
  };

  system = {
    etc.overlay.enable = true;
    tools.nixos-generate-config.enable = false;
  };

  environment = {
    defaultPackages = [ ];
    stub-ld.enable = false;
  };

  programs.command-not-found.enable = false;

  documentation = {
    info.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = [
    pkgs.git
    pkgs.cifs-utils
    pkgs.killall
  ];

  services.timesyncd.enable = true;
  networking.timeServers = [
    "0.pool.ntp.org"
    "1.pool.ntp.org"
    "2.pool.ntp.org"
    "3.pool.ntp.org"
  ];

  i18n.defaultLocale = "en_AU.UTF-8";
  time = {
    timeZone = "Australia/Melbourne";
    hardwareClockInLocalTime = false;
  };

  networking.nftables.enable = true;
  networking.firewall.pingLimit = "2/second";

  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  services.resolved.enable = true;
  networking.nameservers = [
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::fe"
    "2620:fe::9"
  ];

  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        keepEnv = true;
        persist = true;
      }
    ];
  };
}

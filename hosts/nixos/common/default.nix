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

  networking.timeServers = [
    "0.pool.ntp.org"
    "1.pool.ntp.org"
    "2.pool.ntp.org"
    "3.pool.ntp.org"
  ];

  services.timesyncd.enable = true;

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

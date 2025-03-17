{ pkgs, ... }:

{
  imports = [
    ./default/btrfs.nix
    ./default/nix.nix
    ./default/nixpkgs-issue-55674.nix
  ];

  environment.systemPackages = [
    pkgs.age
    pkgs.git
    pkgs.cifs-utils
    pkgs.killall
  ];
  sops.age.keyFile = "/persist/sops/secrets/age/key.txt";

  networking = {
    domain = "mkor.je";
    timeServers = [
      "0.pool.ntp.org"
      "1.pool.ntp.org"
      "2.pool.ntp.org"
      "3.pool.ntp.org"
    ];
  };

  services.timesyncd = {
    enable = true;
  };

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

  # console = {
  #   font = null;
  #   keyMap = "us";
  #   enable = true;
  #   colors = [ ];
  #   packages = [ ];
  #   earlySetup = true;
  #   useXkbConfig = false;
  # };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/log/journal"
    ];
  };
}

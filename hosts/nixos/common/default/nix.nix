{ pkgs, ... }:

{
  # environment.systemPackages = with pkgs; [ cachix ];

  nix = {
    package = pkgs.nixVersions.nix_2_26;
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      tarball-ttl = 0;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.soopy.moe"
        "https://cache.thalheim.io"
        "https://catppuccin.cachix.org"
        "https://helix.cachix.org"
        "https://mkorje.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
        "cache.thalheim.io-1:R7msbosLEZKrxk/lKxf9BTjOOH7Ax3H0Qj0/6wiHOgc="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "mkorje.cachix.org-1:iM64JN6YIX1myYc5JhqjVxgSjNl/zYDHYR+u++ublwM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  system.autoUpgrade = {
    enable = false;
    dates = "daily";
    flake = "git+https://git.mkor.je/mkorje/nixos.git";
  };
}

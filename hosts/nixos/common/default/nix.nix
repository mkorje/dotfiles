{
  nix.channel.enable = false;
  nix.settings = {
    auto-optimise-store = true;
    tarball-ttl = 0;
    warn-dirty = false;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    connect-timeout = 5;
    fallback = true;
    download-buffer-size = 524288000;
    substituters = [
      "https://cache.soopy.moe"
      "https://cache.flox.dev"
      "https://cache.nixos-cuda.org"
      "https://catppuccin.cachix.org"
      "https://helix.cachix.org"
      "https://mkorje.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
      "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "mkorje.cachix.org-1:iM64JN6YIX1myYc5JhqjVxgSjNl/zYDHYR+u++ublwM="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    flake = "github:mkorje/dotfiles";
  };
}

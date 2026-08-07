{ inputs, pkgs, ... }:

{
  allowedUnfreePackages = [
    "steam"
    "steam-original"
    "steam-run"
    "steam-unwrapped"
    "discord"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    prismlauncher
    # dolphin-emu
    # lutris
    # heroic
    # retroarch-free
    inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default

    # mumble
    discord
  ];
}

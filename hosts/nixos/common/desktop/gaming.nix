{ inputs, pkgs, ... }:

{
  allowedUnfreePackages = [
    "steam"
    "steam-unwrapped"
    "discord"
    "discord-unwrapped"
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

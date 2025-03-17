{ inputs, pkgs, ... }:

{
  imports = [
    # sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeManagerModules.catppuccin

    ./cli
    ./code
    ./editor
    ./shell
    ./tty

    ./wayland

    ./email.nix
    ./browsers.nix

    ./science.nix
  ];

  home = {
    username = "mkorje";
    homeDirectory = "/home/mkorje";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  # very nice music player
  services.amberol.enable = true;

  home.packages = with pkgs; [
    # fonts
    nerd-fonts.blex-mono

    keepassxc
    pcmanfm
    #electrum-ltc
    qbittorrent
    signal-desktop
    bitwarden
    bitwarden-cli
    rclone
    glow # markdown viewer
    pandoc

    anki
  ];
}

{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    # sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    inputs.self.homeModules.university

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

  services.udiskie = {
    enable = true;
    settings = {
      device_config = [
        {
          id_label = "ssd";
          options = [
            "noatime"
            "compress-force=zstd:1"
          ];
        }
      ];
    };
  };

  # very nice music player
  services.amberol.enable = true;

  home.packages = with pkgs; [
    # fonts
    nerd-fonts.blex-mono
    arkpandora_ttf
    liberation_ttf

    keepassxc
    gopass
    pcmanfm
    #electrum-ltc
    qbittorrent
    signal-desktop-bin
    bitwarden-desktop
    bitwarden-cli
    rclone
    glow # markdown viewer
    pandoc

    # anki

    # not yet in nixos-unstable
    # filen-cli
    filen-desktop

    simplex-chat-desktop

    # insecure
    # cinny-desktop

    # unfree
    discord
    staruml
  ];
}

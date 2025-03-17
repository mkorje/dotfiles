{ pkgs, ... }:

{
  # file manager
  programs = {
    xplr.enable = true;
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };
    joshuto.enable = true;
    broot = {
      enable = true;
      enableFishIntegration = true;
    };
  };

  programs = {
    # ls replacements
    lsd = {
      enable = false;
      enableAliases = true;
    };
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    # cd replacements
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    # cat replacements
    bat = {
      enable = true;
      config = {
        #theme = cfg.theme;
      };
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batman
        batpipe
        batwatch
        batdiff
        prettybat
      ];
      syntaxes = { };
      themes = { };
    };

    ripgrep.enable = true;

    # find replacement
    fd = {
      enable = true;
      hidden = false;
    };

    # command-line fuzzy finder
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    # process/system monitor
    bottom = {
      enable = true;
      package = pkgs.bottom;
      settings = {
        flags = {
          avg_cpu = true;
          temperature_type = "c";
        };
        #colors = theme;
      };
    };

    # lol
    thefuck = {
      enable = true;
      # enableInstantMode = false;
    };
  };

  home.packages = with pkgs; [
    dust

    trippy
    bandwhich
    kmon
    systeroid

    tokei
    hyperfine

    pastel

    hexyl
  ];
}

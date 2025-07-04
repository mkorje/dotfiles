{ pkgs, ... }:

{
  # file manager
  programs = {
    xplr.enable = true;
    yazi = {
      enable = true;
    };
    joshuto.enable = true;
    broot = {
      enable = true;
    };
  };

  programs = {
    # ls replacements
    lsd = {
      enable = false;
    };
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    # cd replacements
    zoxide = {
      enable = true;
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

    pay-respects.enable = true;
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

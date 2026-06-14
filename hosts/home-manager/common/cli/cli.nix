{ pkgs, ... }:

{
  # file manager
  # should try xplr, broot, joshuto
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
  };

  programs = {
    # ls replacements, lsd is the other alternative
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
      extraPackages = with pkgs.bat-extras; [
        (batgrep.overrideAttrs (_: {
          doCheck = false;
        }))
        batman
        batpipe
        batwatch
        batdiff
        prettybat
      ];
    };

    ripgrep.enable = true;

    # find replacement
    fd.enable = true;

    # command-line fuzzy finder
    fzf = {
      enable = true;
    };

    # process/system monitor
    bottom = {
      enable = true;
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

    tldr
  ];
}

{ pkgs, pkgs-stable, ... }:

{
  home.packages = with pkgs; [
    typst
    hayagriva

    texliveFull

    xournalpp
    libreoffice-fresh
    pkgs-stable.calibre

    orca
    kdePackages.okular
    evince
    papers

    # dictionaries
    hunspell
    hunspellDicts.en_AU

    # fonts
    newcomputermodern
  ];

  programs.zathura = {
    enable = true;
    extraConfig = "";
    mappings = { };
    options = {
      selection-clipboard = "clipboard";
    };
  };

  programs.foliate = {
    enable = true;
    settings = { };
    themes = { };
  };
}

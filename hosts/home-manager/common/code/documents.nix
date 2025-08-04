{ pkgs, pkgs-stable, ... }:

{
  home.packages = with pkgs; [
    typst
    hayagriva

    xournalpp
    libreoffice-fresh
    pkgs-stable.calibre

    # dictionaries
    hunspell
    hunspellDicts.en_AU

    # fonts
    newcomputermodern
  ];

  programs.zathura = {
    enable = true;
    package = pkgs.zathura;
    extraConfig = "";
    mappings = { };
    options = {
      selection-clipboard = "clipboard";
    };
  };
}

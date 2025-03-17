{ pkgs, ... }:

{
  home.packages = with pkgs; [
    typst
    hayagriva

    xournalpp
    libreoffice-fresh
    calibre

    # dictionaries
    hunspell
    hunspellDicts.en_AU

    # fonts
    newcomputermodern
    fontforge-gtk
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

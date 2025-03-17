{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnome-graphs

    # broken
    #kicad # PCB design, see kicadAddons.*
    #freecad # CAD
    zotero
  ];

  # CAS
  programs.sagemath = {
    enable = false;
    package = pkgs.sage;
    # note that the upstream default is ~/.sage
    # configDir = ${config.xdg.configHome}/sage;
    # dataDir = ${config.xdg.dataHome}/sag
    # initScript = "";
  };
}

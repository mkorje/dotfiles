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
  programs.sagemath.enable = true;
}

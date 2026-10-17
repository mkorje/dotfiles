{ pkgs, pkgs-stable, ... }:

{
  home.packages = with pkgs; [
    gnome-graphs

    # broken
    #kicad # PCB design, see kicadAddons.*
    #freecad # CAD
    pkgs-stable.zotero
  ];

  # CAS
  programs.sagemath = {
    enable = true;
    package = pkgs-stable.sage;
  };
}

{ pkgs, pkgs-stable, ... }:

{
  home.packages = with pkgs; [
    gnome-graphs

    # broken
    #kicad # PCB design, see kicadAddons.*
    #freecad # CAD
    zotero
  ];

  # remove with zotero 11
  allowedUnfreePackages = [
    "firefox-esr-140-bin-unwrapped"
  ];
  allowedInsecurePackages = [
    "firefox-esr-140-bin-unwrapped"
  ];

  # CAS
  programs.sagemath = {
    enable = true;
    package = pkgs-stable.sage;
  };
}

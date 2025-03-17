{ pkgs, ... }:

{
  services.mako = {
    enable = true;
    package = pkgs.mako;
    actions = true;
    anchor = "top-right";
    backgroundColor = "";
    borderColor = "";
    borderRadius = 0;
    borderSize = 1;
    defaultTimeout = 0;
    extraConfig = "";
    font = "monospace 10";
    format = "<b>%s</b>\\n%b";
    groupBy = null;
    height = 100;
    iconPath = null;
    icons = true;
    ignoreTimeout = false;
    layer = "top";
    margin = "10";
    markup = true;
    maxIconSize = 64;
    maxVisible = 5;
    output = null;
    padding = "5";
    progressColor = "over #5588AAFF";
    sort = "-time";
    textColor = "#FFFFFFFF";
    width = 300;
  };

  home.packages = with pkgs; [
    xdg-utils
    wl-clipboard
  ];

  # wl-clipboard
  services.cliphist = {
    enable = true;
    package = pkgs.cliphist;
    systemdTarget = "graphical-session.target";
  };
}

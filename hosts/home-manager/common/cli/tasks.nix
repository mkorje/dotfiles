{ pkgs, ... }:

{
  home.packages = with pkgs; [ taskwarrior-tui ];

  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    colorTheme = null;
    config = { };
    dataLocation = "$XDG_DATA_HOME/task";
    extraConfig = "";
  };
}

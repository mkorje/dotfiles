{ inputs, ... }:

{
  imports = [
    ../common
    inputs.self.homeManagerModules.monitors
  ];

  desktop.monitors = [
    {
      name = "eDP-1";
      primary = true;
      width = 2560;
      height = 1600;
      refreshRate = 60;
      scale = 1.6;
      wallpaper = "${inputs.wallpapers}/wallhaven-1pr8q9_2560x1600.png";
    }
  ];
}

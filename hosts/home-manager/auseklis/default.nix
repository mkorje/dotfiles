{ inputs, ... }:

{
  imports = [
    ../common
    inputs.self.homeManagerModules.monitors
  ];

  desktop.monitors = [
    {
      name = "DP-1";
      primary = true;
      width = 2560;
      height = 1440;
      refreshRate = 144;
      wallpaper = "${inputs.wallpapers}/wallhaven-3lrmm9_2560x1440.png";
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      refreshRate = 144;
      x = -1920;
      wallpaper = "${inputs.wallpapers}/wallhaven-3lrmm9_1920x1080.png";
    }
  ];
}

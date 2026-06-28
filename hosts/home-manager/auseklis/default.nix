{ inputs, lib, ... }:

{
  imports = [
    ../common
    inputs.self.homeModules.monitors
  ];

  desktop.monitors = [
    {
      name = "DP-3";
      primary = true;
      width = 2560;
      height = 1440;
      refreshRate = 144;
      wallpaper = ./wallhaven-3lrmm9_2560x1440.png;
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      refreshRate = 144;
      x = -1920;
      wallpaper = ./wallhaven-3lrmm9_1920x1080.png;
    }
  ];

  wayland.windowManager.hyprland.settings.on = {
    _args = [
      "hyprland.start"
      (lib.generators.mkLuaInline ''
        function()
          hl.exec_cmd("uwsm-app -- mullvad-vpn", { workspace = "9 silent" })
          hl.dispatch(hl.dsp.focus({ workspace = 1 }))
        end
      '')
    ];
  };
}

{
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.desktop;

  wallpaperSupportedFormats = [
    ".png"
    ".jpg"
    ".jpeg"
    ".webp"
  ];
  wallpaperTargetDir = "hypr/wallpapers/";

in
{
  options.desktop = {
    monitors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "DP-1";
              description = "";
            };
            primary = mkOption {
              type = types.bool;
              default = false;
              example = true;
              description = "";
            };
            width = mkOption {
              type = types.int;
              example = 1920;
              description = "";
            };
            height = mkOption {
              type = types.int;
              example = 1080;
              description = "";
            };
            refreshRate = mkOption {
              type = types.int;
              example = 60;
              description = "";
            };
            x = mkOption {
              type = types.int;
              default = 0;
              example = -1920;
              description = "";
            };
            y = mkOption {
              type = types.int;
              default = 0;
              example = -1080;
              description = "";
            };
            scale = mkOption {
              type = types.float;
              default = 1.0;
              example = 1.5;
              description = ''
                monitor scaling
              '';
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
              example = false;
              description = "";
            };
            wallpaper = mkOption {
              type = types.nullOr (
                types.path
                // {
                  check =
                    x:
                    (filesystem.pathIsRegularFile x)
                    && (foldl' (a: b: a || (strings.hasSuffix b x)) false wallpaperSupportedFormats);
                }
              );
              default = null;
              description = ''
                path to wallpaper file
              '';
            };
          };
        }
      );
      default = [ ];
      description = ''
        list of monitors to configure
      '';
    };
  };

  config =
    let
      enabledMonitors = filter (x: x.enabled) cfg.monitors;
      primaryMonitors = filter (x: x.primary) enabledMonitors;
      wallpaperMonitors = filter (x: x.wallpaper != null) enabledMonitors;
    in
    {
      assertions = [
        {
          assertion = ((length enabledMonitors) != 0) -> ((length primaryMonitors) == 1);
          message = "exactly one monitor must be the primary";
        }
      ];

      wayland.windowManager.hyprland.settings = {
        monitor =
          (map (
            x:
            "${x.name},${toString x.width}x${toString x.height}@${toString x.refreshRate},${toString x.x}x${toString x.y},${toString x.scale}"
          ) enabledMonitors)
          ++ [
            ",preferred,auto,1"
            "Unknown-1,disable"
          ];
        workspace = mkIf ((length enabledMonitors) != 0) (map (x: "1,monitor:${x.name}") primaryMonitors);
        exec-once = [
          "[workspace 9 silent] uwsm-app -- mullvad-vpn"
          "hyprctl dispatch workspace 1"
        ];
      };

      xdg.configFile = foldl' (
        a: x: a // { "${wallpaperTargetDir}${x.name}".source = x.wallpaper; }
      ) { } wallpaperMonitors;

      services.hyprpaper = {
        enable = true;
        settings = {
          ipc = false;
          splash = false;
          wallpaper = map (x: {
            monitor = x.name;
            path = "${config.xdg.configHome}/${wallpaperTargetDir}${x.name}";
          }) wallpaperMonitors;
        };
      };
    };
}

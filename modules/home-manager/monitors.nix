{
  lib,
  config,
  ...
}:

let
  inherit (lib)
    mkOption
    mkIf
    types
    filter
    length
    foldl'
    strings
    filesystem
    generators
    ;
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
              description = "Connector name of the monitor (as reported by the compositor).";
            };
            primary = mkOption {
              type = types.bool;
              default = false;
              example = true;
              description = "Whether this is the primary monitor. Exactly one enabled monitor must be primary.";
            };
            width = mkOption {
              type = types.int;
              example = 1920;
              description = "Horizontal resolution in pixels.";
            };
            height = mkOption {
              type = types.int;
              example = 1080;
              description = "Vertical resolution in pixels.";
            };
            refreshRate = mkOption {
              type = types.int;
              example = 60;
              description = "Refresh rate in Hz.";
            };
            x = mkOption {
              type = types.int;
              default = 0;
              example = -1920;
              description = "Horizontal position of the monitor's top-left corner in the layout.";
            };
            y = mkOption {
              type = types.int;
              default = 0;
              example = -1080;
              description = "Vertical position of the monitor's top-left corner in the layout.";
            };
            scale = mkOption {
              type = types.float;
              default = 1.0;
              example = 1.5;
              description = "Monitor scaling factor.";
            };
            enabled = mkOption {
              type = types.bool;
              default = true;
              example = false;
              description = "Whether to configure and enable this monitor.";
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
              description = "Path to a wallpaper file for this monitor.";
            };
          };
        }
      );
      default = [ ];
      description = "List of monitors to configure.";
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
          (map (x: {
            output = x.name;
            mode = "${toString x.width}x${toString x.height}@${toString x.refreshRate}";
            position = "${toString x.x}x${toString x.y}";
            inherit (x) scale;
          }) enabledMonitors)
          ++ [
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
            {
              output = "Unknown-1";
              disabled = true;
            }
          ];
        workspace_rule = mkIf ((length enabledMonitors) != 0) (
          map (x: {
            workspace = "1";
            monitor = x.name;
          }) primaryMonitors
        );
        on = {
          _args = [
            "hyprland.start"
            (generators.mkLuaInline ''
              function()
                hl.exec_cmd("uwsm-app -- mullvad-vpn", { workspace = "9 silent" })
                hl.dispatch(hl.dsp.focus({ workspace = 1 }))
              end
            '')
          ];
        };
      };

      xdg.configFile = builtins.listToAttrs (
        map (x: {
          name = "${wallpaperTargetDir}${x.name}";
          value.source = x.wallpaper;
        }) wallpaperMonitors
      );

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

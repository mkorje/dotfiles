{ lib, pkgs, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = null;
    portalPackage = null;
    systemd.enable = false;
    settings = {
      mod._var = "SUPER";

      bind = [
        {
          _args = [
            "SHIFT + CTRL + ALT + BackSpace"
            (mkLuaInline ''hl.dsp.exec_cmd("uwsm stop")'')
          ];
        }

        {
          _args = [
            (mkLuaInline ''mod .. " + Q"'')
            (mkLuaInline "hl.dsp.window.close()")
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + SHIFT + Q"'')
            (mkLuaInline "hl.dsp.window.kill()")
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + RETURN"'')
            (mkLuaInline ''hl.dsp.exec_cmd("uwsm-app -T")'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + SPACE"'')
            (mkLuaInline ''hl.dsp.exec_cmd("uwsm-app -- $(tofi-drun)")'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + F"'')
            (mkLuaInline "hl.dsp.window.fullscreen()")
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + V"'')
            (mkLuaInline ''hl.dsp.exec_cmd("cliphist list | tofi | cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy")'')
          ];
        }

        {
          _args = [
            (mkLuaInline ''mod .. " + H"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "left" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + L"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "right" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + K"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "up" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + J"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "down" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + left"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "left" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + right"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "right" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + up"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "up" })'')
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + down"'')
            (mkLuaInline ''hl.dsp.focus({ direction = "down" })'')
          ];
        }
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          x:
          let
            ws =
              let
                c = (x + 1) / 10;
              in
              builtins.toString (x + 1 - (c * 10));
            workspace = toString (x + 1);
          in
          [
            {
              _args = [
                (mkLuaInline ''mod .. " + ${ws}"'')
                (mkLuaInline "hl.dsp.focus({ workspace = ${workspace} })")
              ];
            }
            {
              _args = [
                (mkLuaInline ''mod .. " + SHIFT + ${ws}"'')
                (mkLuaInline "hl.dsp.window.move({ workspace = ${workspace} })")
              ];
            }
          ]
        ) 10
      ))
      ++ [
        # 274 is middle mouse button
        # 275 is closest side
        # 276 is far side
        {
          _args = [
            (mkLuaInline ''mod .. " + mouse:272"'')
            (mkLuaInline "hl.dsp.window.drag()")
            { mouse = true; }
          ];
        }
        {
          _args = [
            (mkLuaInline ''mod .. " + mouse:273"'')
            (mkLuaInline "hl.dsp.window.resize()")
            { mouse = true; }
          ];
        }
      ];

      animation = {
        leaf = "windows";
        enabled = true;
        speed = 3;
        bezier = "default";
        style = "popin 80%";
      };
      window_rule = {
        name = "librewolf-picture-in-picture";
        match = {
          class = "^(librewolf)$";
          title = "^(Picture-in-Picture)$";
        };
        float = true;
        pin = true;
        size = "800 450";
      };
      config = {
        xwayland.force_zero_scaling = true;
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };
        ecosystem = {
          no_update_news = true;
          no_donation_nag = true;
        };
        gestures = {
          workspace_swipe_distance = 100;
          workspace_swipe_min_speed_to_force = 1;
          workspace_swipe_direction_lock = false;
        };
      };
      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };
    };
  };
}

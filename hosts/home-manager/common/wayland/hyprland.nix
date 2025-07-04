{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";
      exec-once = [
      ];
      bind =
        [
          "SHIFT + CTRL + ALT, BackSpace, exec, uwsm stop"

          "SUPER, Q, killactive"
          "SUPER_SHIFT, Q, forcekillactive"
          "$mod, RETURN, exec, uwsm-app -T"
          "$mod, SPACE, exec, uwsm-app -- $(tofi-drun)"
          "$mod, F, fullscreen"
          "$mod, V, exec, cliphist list | tofi | cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"

          # move focus with $mod + arrow keys and vim keybinds
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
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
            in
            [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          ) 10
        ));
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        #274 is middle mouse button
        #275 is closest side
        #276 is far side
      ];
      animation = [ "windows, 1, 3, default, popin 80%" ];
      windowrule = [
        "float, class:^(librewolf)$, title:^(Picture-in-Picture)$"
        "pin, class:^(librewolf)$, title:^(Picture-in-Picture)$"
        "size 800 450, class:^(librewolf)$, title:^(Picture-in-Picture)$"
      ];
      misc = {
        disable_hyprland_logo = true;
        vfr = true;
      };
      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };
      animations = {
        enabled = true;
      };
      # cursor = {
      #   enable_hyprcursor = false;
      # };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 100;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 1;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_direction_lock = false;
        workspace_swipe_direction_lock_threshold = 10;
        workspace_swipe_forever = false;
        workspace_swipe_use_r = false;
      };
    };
  };
}

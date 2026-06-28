{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Only install the `hyprland-uwsm.desktop` session.
  services.displayManager.sessionPackages = lib.mkForce [
    (pkgs.runCommand "hyprland-uwsm-session"
      {
        passthru.providedSessions = [ "hyprland-uwsm" ];
      }
      ''
        mkdir -p "$out/share/wayland-sessions"
        cp ${config.programs.hyprland.package}/share/wayland-sessions/hyprland-uwsm.desktop \
          "$out/share/wayland-sessions/"
      ''
    )
  ];

  security.rtkit.enable = true;
  services.pipewire.jack.enable = true;

  services.libinput.enable = true;

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --time --remember --remember-session";
  };

  environment.persistence."/persist".directories = [ "/var/cache/tuigreet" ];
}

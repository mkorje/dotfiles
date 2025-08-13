{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.programs) hyprland;
  inherit (pkgs) niri;
in
{
  environment.systemPackages = [
    hyprland.package
    niri
  ];

  programs = {
    dconf.enable = true;
    xwayland.enable = true;
    uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
        niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          binPath = lib.getExe (
            pkgs.writeShellScriptBin "niriSession" ''
              /run/current-system/sw/bin/niri --session
            ''
          );
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    extraPortals = with pkgs; [
      hyprland.portalPackage
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    configPackages = [
      hyprland.package
      niri
    ];
  };

  security.polkit.enable = true;

  services = {
    graphical-desktop.enable = true;
    xserver.desktopManager.runXdgAutostartIfNone = true;
  };

  environment.persistence."/persist" = {
    directories = [ "/var/cache/tuigreet" ];
  };
  # look at theming: https://github.com/apognu/tuigreet?tab=readme-ov-file#theming
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --time --remember --remember-session";
  };
}

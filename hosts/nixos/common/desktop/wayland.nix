{
  config,
  pkgs,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

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

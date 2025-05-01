{
  config,
  pkgs,
  ...
}:

{
  environment.persistence."/persist" = {
    directories = [ "/var/cache/tuigreet" ];
  };
  # look at theming: https://github.com/apognu/tuigreet?tab=readme-ov-file#theming
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --time --remember --remember-session";
  };

  # Compositor
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Authentication agent
  # TODO: install agent
  security.polkit.enable = true;

  # Pipewire
  environment.systemPackages = with pkgs; [
    pwvucontrol
    sonusmix
  ];
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
}

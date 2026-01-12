{ pkgs, config, ... }:

{
  imports = [
    ./gtk.nix
    ./hyprland.nix
    ./tofi.nix
    ./waybar.nix
    ./xdg.nix
  ];

  home.packages = with pkgs; [
    grim
    slurp
  ];

  catppuccin = {
    enable = true;
    accent = "mauve";
    flavor = "mocha";
  };

  # Notification daemon
  services.mako.enable = true;

  # Clipboard manager
  # TODO: https://github.com/Linus789/wl-clip-persist
  services.cliphist.enable = true;

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
}

{ pkgs, ... }:

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

  xdg.configFile."uwsm/env".text = ''
    export NIXOS_OZONE_WL=1
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export LIBVA_DRIVER_NAME=nvidia
  '';
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yubikey-manager
    yubikey-personalization
    yubikey-personalization-gui
    yubico-piv-tool
    yubioath-flutter
  ];
}

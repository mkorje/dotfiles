{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yubikey-manager
    yubico-piv-tool
    yubioath-flutter
  ];
}

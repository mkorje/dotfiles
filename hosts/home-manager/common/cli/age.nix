{ pkgs, ... }:

{
  home.packages = with pkgs; [
    age
    rage
    age-plugin-yubikey
  ];
}

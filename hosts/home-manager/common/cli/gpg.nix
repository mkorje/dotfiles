{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    verbose = true;
  };

  #home.packages = [ pkgs.pinentry-curses ];
}

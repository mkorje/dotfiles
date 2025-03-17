{ pkgs, ... }:

{
  imports = [ ./prompt.nix ];

  programs.fish = {
    enable = true;
    package = pkgs.fish;
    functions = {
      "nixos-switch" = ''
        if not count $argv > /dev/null
          read drv
        else
          set -f drv $argv[1]
        end
        doas nix-env -p /nix/var/nix/profiles/system --set $drv
        doas $drv/bin/switch-to-configuration switch
      '';
    };
    generateCompletions = true;
    interactiveShellInit = ''
      set -g fish_greeting
    '';
    loginShellInit = "";
    plugins = [ ];
    shellAbbrs = { };
    shellAliases = { };
    shellInit = "";
  };
}

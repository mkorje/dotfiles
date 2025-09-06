{ pkgs, ... }:

{
  imports = [ ./prompt.nix ];

  programs.fish = {
    enable = true;
    package = pkgs.fish;
    functions = {
      # Usage:
      # nix build --print-out-paths .#nixosConfigurations.<HOSTNAME>.config.system.build.toplevel | nixos-switch
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
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    exitShellOnExit = true;
    settings = {
      on_force_close = "quit";
      pane_frames = false;
      default_layout = "compact";
      ui.pane_frames.hide_session_name = true;
      show_startup_tips = false;
      show_release_notes = false;
    };
  };
}

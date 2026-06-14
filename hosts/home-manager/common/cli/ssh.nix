{ pkgs, ... }:

let
  gitIdentityFile = "~/.ssh/id_ed25519_sk_rk_git-auth";

in
{
  home.packages = [ (pkgs.callPackage ./pkgs/uni-connect.nix { }) ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        User = "git";
        IdentityFile = gitIdentityFile;
      };

      "codeberg.org" = {
        User = "git";
        IdentityFile = gitIdentityFile;
      };

      "git.sr.ht" = {
        User = "git";
        IdentityFile = gitIdentityFile;
      };

      "gitlab.com" = {
        User = "git";
        IdentityFile = gitIdentityFile;
      };

      "swen20003.eng.unimelb.edu.au" = {
        User = "git";
        IdentityFile = gitIdentityFile;
      };

      "spartan" = {
        User = "kortgem";
        HostName = "spartan.hpc.unimelb.edu.au";
        ProxyCommand = "uni-connect %h %p";
        ControlPersist = "no";
      };

      "meness" = {
        User = "admin";
        HostName = "172.16.1.100";
        IdentityFile = "~/.ssh/id_ed25519_sk_rk_nixos";
      };

      "hermes" = {
        User = "admin";
        HostName = "139.84.200.35";
        IdentityFile = "~/.ssh/id_ed25519_sk_rk_nixos";
      };

      "*" = {
        AddKeysToAgent = "no";
        Compression = true;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control-%r@%h:%p";
        ControlPersist = "10m";
        IPQoS = "none";
        IdentitiesOnly = true;
      };
    };
  };
}

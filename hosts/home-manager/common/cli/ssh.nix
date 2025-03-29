{ pkgs, ... }:

let
  gitIdentityFile = "~/.ssh/id_ed25519_sk_rk_git-auth";

in
{
  home.packages = [ (pkgs.callPackage ./pkgs/uni-connect.nix { }) ];

  programs.ssh = {
    enable = true;
    addKeysToAgent = "no";
    compression = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/control-%r@%h:%p";
    controlPersist = "10m";
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = gitIdentityFile;
      };

      "codeberg.org" = {
        user = "git";
        identityFile = gitIdentityFile;
      };

      "git.sr.ht" = {
        user = "git";
        identityFile = gitIdentityFile;
      };

      "gitlab.com" = {
        user = "git";
        identityFile = gitIdentityFile;
      };

      "comp30023" = {
        user = "mkortge";
        hostname = "172.26.130.140";
        proxyCommand = "uni-connect %h %p";
        extraOptions.controlPersist = "no";
      };

      "*" = {
        identitiesOnly = true;
      };
    };
  };
}

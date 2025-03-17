let
  gitIdentityFile = "~/.ssh/id_ed25519_sk_rk_git-auth";

in
{
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

      "*" = {
        identitiesOnly = true;
      };
    };
  };
}

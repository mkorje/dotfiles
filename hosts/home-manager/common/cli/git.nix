{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;

    signing = {
      key = "~/.ssh/id_ed25519_sk_rk_git-sign.pub";
      signByDefault = true;
    };
    settings = {
      user.email = "max@mkor.je";
      user.name = "mkorje";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      push.autoSetupRemote = true;
      log.date = "iso";
    };

    # delta = {
    #   enable = true;
    # };
    # diff-so-fancy = {
    #   enable = true;
    # };
    # use `git diff --no-ext-diff` to do patches!
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

  programs.gitui.enable = false;

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "mkorje";
        email = "max@mkor.je";
      };
      ui = {
        paginate = "never";
        default-command = [
          "log"
          "--reversed"
        ];
      };
      signing = {
        behavior = "drop";
        backend = "ssh";
        key = "~/.ssh/id_ed25519_sk_rk_git-sign.pub";
      };
      git.sign-on-push = true;
    };
  };
}

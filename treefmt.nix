{ pkgs, ... }:

{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "LICENSE.txt"
    "**/secrets.yaml"
  ];

  programs.typos = {
    enable = true;
    hidden = true;
  };

  programs.mdformat.enable = true;
  settings.formatter.markdownlint = {
    command = "${pkgs.markdownlint-cli}/bin/markdownlint";
    options = [
      "-f"
      "--disable"
      "MD013"
      "--"
    ];
    includes = [ "*.md" ];
  };

  programs.nixfmt.enable = true;
  programs.deadnix.enable = true;
  programs.statix.enable = true;

  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
  programs.fish_indent.enable = true;

  programs.yamlfmt.enable = true;
  programs.actionlint.enable = true;
}

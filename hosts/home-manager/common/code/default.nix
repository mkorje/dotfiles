{ pkgs, ... }:

{
  imports = [
    ./documents.nix
  ];

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
    '')
    qemu
    nasm

    watchexec

    clippy
    rustc
    cargo
    rustfmt
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };
}

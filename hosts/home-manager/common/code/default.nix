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
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = false;
    #enableFishIntegration = true;
    enableNushellIntegration = false;
    enableZshIntegration = false;
    #config = { };
    nix-direnv.enable = true;
    #stdlib = "";
  };
}

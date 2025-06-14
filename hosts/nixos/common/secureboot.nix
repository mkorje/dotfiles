{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    configurationLimit = 5;
    pkiBundle = "/persist/secureboot";
  };

  environment.systemPackages = [
    pkgs.tpm2-tools
    (pkgs.sbctl.override { databasePath = config.boot.lanzaboote.pkiBundle; })
  ];
}

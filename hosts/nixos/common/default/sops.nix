{
  inputs,
  pkgs,
  hostName,
  ...
}:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile = ../../${hostName}/secrets.yaml;

  environment.systemPackages = [ pkgs.age ];

  sops.age.keyFile = "/persist/sops/secrets/age/key.txt";
}

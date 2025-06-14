{
  inputs,
  pkgs,
  hostName,
  ...
}:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [ pkgs.age ];

  sops.defaultSopsFile = ../../${hostName}/secrets.yaml;
  sops.age.keyFile = "/persist/sops/secrets/age/key.txt";
}

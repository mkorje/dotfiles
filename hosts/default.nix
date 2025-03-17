{ inputs }:

let
  mkSystem =
    {
      hostName,
      system ? "x86_64-linux",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit hostName;
        # vars = {
        #   username = "";
        #   name = "";
        #   email = "";
        # };
      };
      modules = [
        inputs.impermanence.nixosModules.impermanence
        inputs.sops-nix.nixosModules.sops
        inputs.catppuccin.nixosModules.catppuccin
        ./nixos/${hostName}
        {
          networking.hostName = hostName;
          sops.defaultSopsFile = ./nixos/${hostName}/secrets.yaml;
          nixpkgs.hostPlatform = system;
        }
      ];
    };

in
{
  auseklis = mkSystem { hostName = "auseklis"; };
  aizsaule = mkSystem { hostName = "aizsaule"; };
}

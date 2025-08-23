{ inputs }:

let
  mkSystem =
    {
      hostName,
      system ? "x86_64-linux",
      domain ? "mkor.je",
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit hostName;
        inherit domain;
        pkgs-stable = import inputs.nixpkgs-stable {
          inherit system;
        };
        # vars = {
        #   username = "";
        #   name = "";
        #   email = "";
        # };
      };
      modules = [
        ./nixos/${hostName}
        {
          networking = {
            inherit hostName;
            inherit domain;
          };
          nixpkgs.hostPlatform = system;
        }
      ];
    };

in
{
  auseklis = mkSystem { hostName = "auseklis"; };
  aizsaule = mkSystem { hostName = "aizsaule"; };

  lietuvens = mkSystem { hostName = "lietuvens"; };

  hermes = mkSystem {
    hostName = "hermes";
    domain = "pist.is";
  };
}

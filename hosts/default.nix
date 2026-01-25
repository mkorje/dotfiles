{ inputs }:

let
  mkSystem =
    {
      hostName,
      system ? "x86_64-linux",
      domain ? "mkor.je",
      stable ? false,
    }:
    (if stable then inputs.nixpkgs-stable else inputs.nixpkgs).lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs hostName domain;
      }
      // (
        if stable then
          { pkgs-unstable = import inputs.nixpkgs { inherit system; }; }
        else
          { pkgs-stable = import inputs.nixpkgs-stable { inherit system; }; }
      );

      modules = [
        inputs.self.nixosModules.nvidia
        ./nixos/${hostName}
        {
          networking = { inherit hostName domain; };
          nixpkgs.hostPlatform = system;
        }
      ];
    };

in
{
  auseklis = mkSystem { hostName = "auseklis"; };
  aizsaule = mkSystem { hostName = "aizsaule"; };

  meness = mkSystem {
    hostName = "meness";
    domain = "pist.is";
    stable = true;
  };

  laima = mkSystem {
    hostName = "laima";
    domain = "elp.is";
    stable = true;
  };
}

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

  meness = mkSystem {
    hostName = "meness";
    domain = "pist.is";
  };
  # lietuvens = mkSystem {
  #   hostName = "lietuvens";
  #   domain = "pist.is";
  # };
  # hermes = mkSystem {
  #   hostName = "hermes";
  #   domain = "pist.is";
  # };
}

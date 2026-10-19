{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  hasHomeManager = options ? home-manager;
  hmPackages =
    option:
    if hasHomeManager then
      lib.concatLists (lib.mapAttrsToList (_: cfg: cfg.${option} or [ ]) config.home-manager.users)
    else
      [ ];
  allUnfreePackages = config.allowedUnfreePackages ++ hmPackages "allowedUnfreePackages";
  allInsecurePackages = config.allowedInsecurePackages ++ hmPackages "allowedInsecurePackages";
in
{
  options = {
    allowedUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Unfree packages allowed at the system level.";
    };

    allowedInsecurePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Insecure packages allowed at the system level.";
    };
  };

  config = lib.mkMerge [
    {
      nixpkgs.config = {
        allowUnfreePredicate =
          pkg:
          (builtins.elem (lib.getName pkg) allUnfreePackages)
          || (config.nvidia.cuda && (pkgs._cuda.lib.allowUnfreeCudaPredicate pkg));

        allowInsecurePredicate = pkg: (builtins.elem (lib.getName pkg) allInsecurePackages);
      };
    }

    (lib.optionalAttrs hasHomeManager {
      home-manager.sharedModules = [
        {
          options = {
            allowedUnfreePackages = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Unfree packages allowed for this Home Manager user.";
            };

            allowedInsecurePackages = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Insecure packages allowed for this Home Manager user.";
            };
          };
        }
      ];
    })
  ];
}

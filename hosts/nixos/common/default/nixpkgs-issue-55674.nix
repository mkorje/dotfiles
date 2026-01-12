{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  hasHomeManager = options ? home-manager;
  hmUnfreePackages =
    if hasHomeManager then
      lib.concatLists (
        lib.mapAttrsToList (_: cfg: cfg.allowedUnfreePackages or [ ]) config.home-manager.users
      )
    else
      [ ];
  allUnfreePackages = config.allowedUnfreePackages ++ hmUnfreePackages;
in
{
  options.allowedUnfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Unfree packages allowed at the system level.";
  };

  config = lib.mkMerge [
    {
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        (builtins.elem (lib.getName pkg) allUnfreePackages)
        || (config.nvidia.cuda && (pkgs._cuda.lib.allowUnfreeCudaPredicate pkg));
    }

    (lib.optionalAttrs hasHomeManager {
      home-manager.sharedModules = [
        {
          options.allowedUnfreePackages = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Unfree packages allowed for this Home Manager user.";
          };
        }
      ];
    })
  ];
}

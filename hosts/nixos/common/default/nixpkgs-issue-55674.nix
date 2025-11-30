{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.allowedUnfreePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config.nixpkgs.config.allowUnfreePredicate =
    pkg:
    (builtins.elem (lib.getName pkg) config.allowedUnfreePackages)
    || (config.nvidia.cuda && (pkgs._cuda.lib.allowUnfreeCudaPredicate pkg));
}

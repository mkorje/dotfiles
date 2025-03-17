{ inputs, hostName, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.mkorje = import ./${hostName};
  home-manager.extraSpecialArgs = {
    inherit inputs;
    inherit hostName;
  };
}

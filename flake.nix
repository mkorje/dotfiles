{
  description = "mkorje's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wallpapers = {
      url = "github:mkorje/wallpapers";
      flake = false;
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:

    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      treefmt = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      nixosModules = import ./modules/nixos;
      homeModules = import ./modules/home-manager;

      nixosConfigurations = import ./hosts { inherit inputs; };

      formatter."x86_64-linux" = treefmt.config.build.wrapper;

      checks."x86_64-linux" = {
        formatting = treefmt.config.build.check self;
      };
    };
}

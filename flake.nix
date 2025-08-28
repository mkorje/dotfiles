{
  description = "mkorje's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:mkorje/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
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

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-frigate.url = "github:NixOS/nixpkgs?rev=dafd0cf5690607735121f2d63adcb07df9a49704";
    frigate.url = "github:mkorje/frigate?ref=v0.15.2";

    wallpapers = {
      url = "github:mkorje/wallpapers";
      flake = false;
    };

    starship-nerd-font-symbols = {
      url = "https://starship.rs/presets/toml/nerd-font-symbols.toml";
      flake = false;
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

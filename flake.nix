{
  description = "mkorje's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

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

    tensorflow.url = "github:mkorje/tensorflow";

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
      overlay = self: super: {
        python312 = super.python312.override {
          packageOverrides = _: pysuper: {
            tensorflow-bin = pysuper.tensorflow-bin.overridePythonAttrs (_: {
              pname = "tensorflow";
              version = "2.19.0";
              src = super.fetchurl {
                url = "https://github.com/mkorje/tensorflow/releases/download/v2.19.0-312/tensorflow_cpu-2.19.0-cp312-cp312-linux_x86_64.whl";
                sha256 = "12qz7lwf2knhxxn6yw3xvljahn8gz0zfl2kil9hkxm6mzp22xx40";
              };
            });
          };
        };
        frigate = super.frigate.override {
          inherit (self) python312;
        };
      };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
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

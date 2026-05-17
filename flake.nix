{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [ dbus.dev pkg-config ];
    };

    nixosConfigurations = {
      desktop = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; greeterPath = ./ivyshell/greeter; };
        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/appearance.nix
          ./modules/common.nix
          ./modules/creative.nix
          ./modules/gaming.nix
          ./modules/keyd.nix
          ./modules/ivyshell.nix
          ./modules/nixvim.nix
          ./modules/llms.nix
          inputs.home-manager.nixosModules.home-manager
          inputs.nixvim.nixosModules.nixvim
          {
            nixpkgs.overlays = [
              inputs.quickshell.overlays.default
              (final: prev: {
                unstable = import inputs.nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
                shellv2 = prev.callPackage ./ivyshell/shellv2/package.nix { };
              })
            ];
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.ivy       = import ./ivyshell/ivyshell.nix;
          }
        ];
      };

      laptop = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; greeterPath = ./ivyshell/greeter; };
        modules = [
          ./hosts/laptop/configuration.nix
          ./modules/appearance.nix
          ./modules/common.nix
          ./modules/ivyshell.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.quickshell.overlays.default
              (final: prev: {
                unstable = import inputs.nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };
                shellv2 = prev.callPackage ./ivyshell/shellv2/package.nix { };
              })
            ];
            home-manager.useGlobalPkgs   = true;
            home-manager.useUserPackages = true;
            home-manager.users.ivy       = import ./ivyshell/ivyshell.nix;
          }
        ];
      };
    };
  };
}
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: {
    nixosConfigurations = {
      desktop = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/desktop/configuration.nix
          ./modules/appearance.nix
          ./modules/common.nix
          ./modules/creative.nix
          ./modules/gaming.nix
          ./modules/keyd.nix
          ./modules/ivyshell.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ inputs.quickshell.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ivy = import ./ivyshell/ivyshell.nix;
          }
        ];
      };
      laptop = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/laptop/configuration.nix
          ./modules/appearance.nix
          ./modules/common.nix
          ./modules/ivyshell.nix
          inputs.home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ inputs.quickshell.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ivy = import ./ivyshell/ivyshell.nix;
          }
        ];
      };
    };
  };
}

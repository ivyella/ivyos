
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = inputs: {
    nixosConfigurations = {
      mikoshi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/mikoshi/configuration.nix ];
      };
      izanagi = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/izanagi/configuration.nix ];
      };
    };
  };
}

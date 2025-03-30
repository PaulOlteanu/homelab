{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixos-generators,
    ...
  }: {
    packages.x86_64-linux = {
      proxmox-img = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          ./configurations/base.nix
        ];
        format = "proxmox";
      };
    };

    nixosConfigurations.nixos-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/base.nix
        ./configurations/nixos-1.nix
      ];
    };

    nixosConfigurations.nixos-2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/base.nix
        ./configurations/nixos-2.nix
      ];
    };

    nixosConfigurations.nixos-3 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/base.nix
        ./configurations/nixos-3.nix
      ];
    };
  };
}

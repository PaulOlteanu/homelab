{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-generators,
    deploy-rs,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {inherit system;};

    deployPkgs = import nixpkgs {
      inherit system;
      overlays = [
        deploy-rs.overlay
        (final: prev: {
          deploy-rs = {
            inherit (pkgs) deploy-rs;
            lib = prev.deploy-rs.lib;
          };
        })
      ];
    };

    system-names = ["nixos-1" "nixos-2" "nixos-3"];

    mkSystem = name:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configurations/base.nix
          ./configurations/common.nix
          ./configurations/${name}.nix
        ];
      };

    mkDeploy = name: {
      hostname = name;
      profiles.system = {
        user = "root";
        sshUser = "nixos";
        path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${name};
      };
    };
  in {
    packages.x86_64-linux = {
      proxmox-img = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          ./configurations/base.nix
        ];
        format = "proxmox";
      };
    };

    nixosConfigurations = nixpkgs.lib.genAttrs system-names mkSystem;
    deploy.nodes = nixpkgs.lib.genAttrs system-names mkDeploy;

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

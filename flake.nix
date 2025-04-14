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

    # TODO: How do I dedupe this stuff
    nixosConfigurations.nixos-1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/base.nix
        ./configurations/common.nix
        ./configurations/nixos-1.nix
      ];
    };

    nixosConfigurations.nixos-2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/base.nix
        ./configurations/common.nix
        ./configurations/nixos-2.nix
      ];
    };

    nixosConfigurations.nixos-3 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configurations/base.nix
        ./configurations/common.nix
        ./configurations/nixos-3.nix
      ];
    };

    deploy.nodes.nixos-1 = {
      hostname = "nixos-1";
      profiles.system = {
        user = "root";
        sshUser = "nixos";
        path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.nixos-1;
      };
    };
    deploy.nodes.nixos-2 = {
      hostname = "nixos-2";
      profiles.system = {
        user = "root";
        sshUser = "nixos";
        path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.nixos-2;
      };
    };
    deploy.nodes.nixos-3 = {
      hostname = "nixos-3";
      profiles.system = {
        user = "root";
        sshUser = "nixos";
        path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.nixos-3;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}

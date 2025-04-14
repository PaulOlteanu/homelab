{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  config = {
    networking.hostName = "nixos-1";

    networking.firewall.allowedTCPPorts = [
      80
      443
      6443 # k32 API server
      2379 # k3s etcd clients
      2380 # k3s etcd peers
      7946 # metallb
    ];
    networking.firewall.allowedUDPPorts = [
      8437 # k3s flannel
      7946 # metallb
      8472 # metallb
    ];

    services.k3s = {
      enable = true;
      role = "server";
      clusterInit = true;
      extraFlags = [
        "--disable traefik"
        "--disable servicelb"
      ];
    };

    environment.systemPackages = with pkgs; [
      htop
      helix
    ];
  };
}

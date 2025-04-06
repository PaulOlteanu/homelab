{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  config = {
    networking.hostName = "nixos-2";

    networking.firewall.allowedTCPPorts = [
      6443 # k32 API server
      2379 # k3s etcd clients
      2380 # k3s etcd peers
    ];
    networking.firewall.allowedUDPPorts = [
      8437 # k3s flannel
    ];

    services.k3s = {
      enable = true;
      role = "server";
      tokenFile = "/etc/k3s-token";
      extraFlags = [
        "--disable traefik"
      ];
      serverAddr = "https://192.168.0.187:6443";
    };

    environment.systemPackages = with pkgs; [
      htop
      helix
    ];
  };
}

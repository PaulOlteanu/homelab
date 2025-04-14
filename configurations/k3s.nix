{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.k3s;
in {
  options.k3s = {
    enable = mkEnableOption "k3s service";

    cluster-init = mkOption {
      type = types.bool;
      default = false;
      description = "whether this node should initialize a new cluster";
    };

    server-ip = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The IP address of the cluster's main server.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.cluster-init || cfg.server-ip != null;
        message = "server-ip must be set if cluster-init is false.";
      }
    ];

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

    services.k3s = mkMerge [
      {
        enable = true;
        role = "server";
        extraFlags = [
          "--disable traefik"
          "--disable servicelb"
        ];
      }

      (mkIf cfg.cluster-init
        {
          clusterInit = true;
        })

      (mkIf (!cfg.cluster-init)
        {
          tokenFile = "/etc/k3s-token";
          serverAddr = "https://${cfg.server-ip}:6443";
        })
    ];
  };
}

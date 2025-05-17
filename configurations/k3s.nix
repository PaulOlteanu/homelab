{
  config,
  lib,
  pkgs,
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
      description = "Whether this node should initialize a new cluster.";
    };

    server-ip = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "The IP address of the cluster's main server.";
    };

    enable-longhorn = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this node should be configured for running longhorn. This will install openiscsi, and attempt to mount an ext4 formatted disk with a label of `longhorn` to `/mnt/longhorn`";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.cluster-init || cfg.server-ip != null;
          message = "server-ip must be set if cluster-init is false.";
        }
      ];

      networking.firewall.allowedTCPPorts = [
        80
        443
        2379 # k3s etcd clients
        2380 # k3s etcd peers
        6443 # k32 API server
        7946 # metallb
        9100 # node-exporter?
        10250 # node-exporter
      ];
      networking.firewall.allowedUDPPorts = [
        8437 # k3s flannel
        8472 # metallb
        7946 # metallb
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

      services.avahi.enable = true;
      services.avahi.openFirewall = true;
      services.avahi.publish.addresses = true;
      services.avahi.nssmdns = true;
    }

    (mkIf cfg.enable-longhorn {
      environment.systemPackages = [pkgs.nfs-utils];
      services.openiscsi = {
        enable = true;
        name = "${config.networking.hostName}-initiatorhost";
      };

      # Workaround for longhorn because it expects binaries at /usr/local/bin
      systemd.tmpfiles.rules = [
        "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      ];

      fileSystems."/mnt/longhorn" = {
        device = "/dev/disk/by-label/longhorn";
        fsType = "ext4";
        options = ["defaults" "nofail"];
      };
    })
  ]);
}

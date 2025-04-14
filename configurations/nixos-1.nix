{...}: {
  imports = [./k3s.nix];
  config = {
    networking.hostName = "nixos-1";

    k3s.enable = true;
    k3s.cluster-init = true;
  };
}

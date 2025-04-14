{...}: {
  imports = [./k3s.nix];
  config = {
    networking.hostName = "nixos-3";

    k3s.enable = true;
    k3s.server-ip = "192.168.0.187";
  };
}

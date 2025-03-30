{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  config = {
    networking.hostName = "nixos-1";

    environment.systemPackages = with pkgs; [
      htop
    ];
  };
}

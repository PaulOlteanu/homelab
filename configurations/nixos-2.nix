{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  config = {
    networking.hostName = "nixos-2";

    environment.systemPackages = with pkgs; [
      bottom
    ];
  };
}

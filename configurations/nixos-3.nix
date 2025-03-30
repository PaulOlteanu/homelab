{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  config = {
    networking.hostName = "nixos-3";

    environment.systemPackages = with pkgs; [
      python311
    ];
  };
}

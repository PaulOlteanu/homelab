{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  config = {
    networking.hostName = "nixos-1";

    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUs4mKE2IT8jzhOrosHF56Oi3AdG71h7aONIKvPM8pv p.a.olteanu@gmail.com"
    ];

    environment.systemPackages = with pkgs; [
      htop
    ];
  };
}

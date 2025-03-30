{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    #Provide a default hostname
    networking.hostName = lib.mkDefault "nixos";
    networking.useDHCP = lib.mkDefault true;

    # Enable QEMU Guest for Proxmox
    services.qemuGuest.enable = lib.mkDefault true;

    # Use the boot drive for grub
    boot.loader.grub.enable = lib.mkDefault true;
    boot.loader.grub.devices = ["nodev"];

    boot.growPartition = lib.mkDefault true;

    nix.settings.experimental-features = ["nix-command" "flakes"];

    # Allow remote updates with flakes and non-root users
    nix.settings.trusted-users = ["root" "@wheel"];

    # We need to create a user here instead of through cloud-init so that we can add them to wheel
    # and then allow them to use password-less sudo. Otherwise we have no way of getting root access.
    # We can still specify the initial ssh key through cloud-init however.
    users.users.nixos = {
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
    };
    security.sudo.wheelNeedsPassword = false;

    # Enable ssh
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    programs.ssh.startAgent = true;

    # Some sane packages we need on every system
    environment.systemPackages = with pkgs; [
      helix
      neovim
      vim
    ];

    # Default filesystem
    fileSystems."/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    system.stateVersion = lib.mkDefault "25.05";
  };
}

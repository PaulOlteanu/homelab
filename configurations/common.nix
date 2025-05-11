{
  pkgs,
  lib,
  ...
}: {
  config = {
    users.users.nixos.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINa4WrJTh45V4PfRjp5bhWP5L8i9E7TeISs6iNtEzid4"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOQ5VPqQ/UMJcyJtzh/snKm1FsRk+I/mX0YMgk51bEB"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO6xWqvnNNGBJ3Rk0vy8Ofm0s9CKfP7k5HTHhKM+XeIW"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUs4mKE2IT8jzhOrosHF56Oi3AdG71h7aONIKvPM8pv"
    ];

    environment.enableAllTerminfo = true;

    environment.systemPackages = with pkgs; [
      htop
      helix
    ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Stuff taken from srvos
    boot.tmp.cleanOnBoot = lib.mkDefault true;
    boot.loader.grub.configurationLimit = lib.mkDefault 5;
    boot.loader.systemd-boot.configurationLimit = lib.mkDefault 5;

    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;

    fonts.fontconfig.enable = lib.mkDefault false;
    programs.command-not-found.enable = lib.mkDefault false;

    systemd = {
      # Given that our systems are headless, emergency mode is useless.
      # We prefer the system to attempt to continue booting so
      # that we can hopefully still access it remotely.
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 7.5s.
        # If the hardware watchdog does not get a signal for 15s,
        # it will forcefully reboot the system.
        runtimeTime = lib.mkDefault "15s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = lib.mkDefault "30s";
        # Forcefully reboot when a host hangs after kexec.
        # This may be the case when the firmware does not support kexec.
        kexecTime = lib.mkDefault "1m";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}

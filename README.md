`nix build .#proxmox-img` to create a proxmox backup file. This is then restored in proxmox and turned into a template

`nixos-rebuild switch --flake .#nixos-n --target-host nixos-n --use-remote-sudo` to update the config for `nixos-n` (after setting up the correct .ssh/config entry). Eventually this should be `deploy-rs` or `comin`.

# TODO
* Figure out keeping disk not bloated (i.e. old generations, removed packages, etc.)
* Better way of managing common config

`nix build .#proxmox-img` to create a proxmox backup file. This is then restored in proxmox and turned into a template.

`deploy` to deploy the configurations to the nodes (or `deploy --targets .#nixos-[1,2,3]` to deploy a specific config).

# configurations/
* `base.nix`: the base configuration used in the `proxmox-img` ourput.
* `common.nix`: shared configuration for all nodes. Currently just all my ssh public keys.
* `nixos-[1,2,3]`: nodes running k3s. `nixos-1` is the master (`cluster-init` enabled). All 3 are running as k3s `server`s, so they all run control-plane components.
* `k3s.nix`: a nixos module for enabling k3s on a node. This will open some ports on the node and run k3s with traefik and servicelb disabled.

# TODO
* Way to manage k3s secrets from here instead of sshing into nodes.
* Way to make longhorn configuration less manual

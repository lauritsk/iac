# Homelab IaC

OpenTofu configuration for my Incus homelab and Tailscale tailnet.

Managed from my MacBook using local credentials and local OpenTofu state. State recovery should remain independent of the homelab.

Requires OpenTofu, Incus, just, hujsonfmt, and `docker-credential-osxkeychain`. Local environment settings are loaded from `.env` by just; inputs are defined in `variables.tofu`.

Run `just` to list commands. Use `just plan` to review infrastructure changes before `just apply`.

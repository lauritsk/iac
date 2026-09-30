# Homelab IaC

OpenTofu configuration for my Incus homelab and Tailscale tailnet.

Managed from my MacBook using local credentials and local OpenTofu state. State recovery should remain independent of the homelab.

Requires OpenTofu, Incus, just, hujsonfmt, and `docker-credential-osxkeychain`. Local environment settings are loaded from `.env` by just; inputs are defined in `main.tofu`.

Run `just` to list commands. Use `just plan` to review infrastructure changes before `just apply`.

Jellyfin uses the dedicated `jellyfin-ts` Incus container, with Tailscale hostname `jellyfin`, kernel networking, and HTTPS Serve at https://jellyfin.cormo-tegu.ts.net. Its gateway, persistent identity, and Serve configuration are declared in `jellyfin.tofu`. The shared proxy serves the remaining applications.

To test cross-tailnet access, share the `jellyfin` node from the Tailscale Machines page with one external user. Have them accept while using their own tailnet, open the HTTPS URL, sign in to Jellyfin, and test playback and seeking. The policy permits shared recipients only TCP 443 on this node. Confirm your tailnet user count stays unchanged and revoking the share removes their access.

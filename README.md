# Homelab IaC

Requires:

- Homebrew: `opentofu`, `incus`, `just`, `docker-credential-helper`, `go`.
- `hujsonfmt`: `go install github.com/tailscale/hujson/cmd/hujsonfmt@latest`.
- Tailscale access to `hv01` and local Incus credentials.
- `.env` with Tailscale OAuth credentials, API keys, and the state passphrase.
- Local `terraform.tfstate`; keep state backups and the passphrase independent of the homelab.

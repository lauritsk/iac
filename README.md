# Homelab IaC

OpenTofu configuration for my Incus homelab and Tailscale tailnet, managed from my MacBook.

Install the Homebrew dependencies:

```sh
brew install opentofu incus just docker-credential-helper go
go install github.com/tailscale/hujson/cmd/hujsonfmt@latest
```

Ensure `hujsonfmt` is on `PATH` (normally `~/go/bin`). `docker-credential-helper` provides `docker-credential-osxkeychain` on macOS.

The following must also be present:

- Tailscale connectivity to `hv01` and trusted Incus client credentials in `~/Library/Application Support/incus`.
- A local `.env` with `TAILSCALE_OAUTH_CLIENT_ID`, `TAILSCALE_OAUTH_CLIENT_SECRET`, `TF_VAR_state_passphrase`, and `TF_VAR_prowlarr_api_key`, `TF_VAR_radarr_api_key`, `TF_VAR_sonarr_api_key`. `just` loads it automatically.
- The existing encrypted `terraform.tfstate` and its encryption passphrase when managing this homelab. Keep state backups and the passphrase recoverable independently of the homelab.

Run `just` to list recipes; review `just plan` before `just apply`.

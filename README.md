# Homelab IaC

[IncusOS host configuration](INCUSOS.md) records live host settings that are not managed by OpenTofu, including updates, networking, Tailscale, and backing storage.

## Transmission peer forwarding

`transmission.tofu` manages an Incus network forward from `10.1.10.8:51413` to Transmission's container address, for TCP and UDP only. Port `9091` is not forwarded.

The RouterOS gateway at `admin@10.1.10.1` has two persistent IPv4 destination NAT rules, configured outside OpenTofu:

- Comments: `Transmission peer tcp` and `Transmission peer udp`.
- Match: `chain=dstnat`, `in-interface-list=WAN`, `dst-address-type=local`, `dst-port=51413`, and the respective protocol.
- Action: `dst-nat` to `10.1.10.8:51413`, the host's reserved DHCP address.
- The existing forward firewall allows destination-NAT traffic; no management/input firewall rules were changed.

Verify externally from Transmission with `curl -4 https://portcheck.transmissionbt.com/51413`; `1` means open. IPv6 peer forwarding is not configured, so Transmission's built-in check may report closed when it checks IPv6.

To close access at the router, disable both NAT rules by their exact comments. Remove `incus_network_forward.transmission_peer` and apply OpenTofu to remove the host forward as well.

## Blog: Cloudflare Tunnel

`blog.tofu` manages a remotely configured `blog` tunnel, routing for `blog.laurits.dev`, and a proxied CNAME in the `laurits.dev` zone. Caddy, Hugo publishing, and the cloudflared connector are not yet deployed by this configuration.

Create a Cloudflare API token with **Account → Cloudflare Tunnel → Edit** for the intended account and **Zone → DNS → Edit** restricted to `laurits.dev`. Set these values in the ignored local `.env`:

```dotenv
CLOUDFLARE_API_TOKEN=your-scoped-api-token
TF_VAR_cloudflare_account_id=your-32-character-account-id
TF_VAR_cloudflare_zone_id=your-32-character-laurits-dev-zone-id
TF_VAR_blog_origin_url=http://your-internal-caddy-address:8080
```

The account and zone IDs are available in the Cloudflare dashboard. The origin must be reachable from the future cloudflared connector; it is not the public blog URL. The provider reads `CLOUDFLARE_API_TOKEN` directly, without using the cloudflared login certificate.

Run `just plan` and review it before `just apply`. If a DNS record for `blog.laurits.dev` or a tunnel named `blog` already exists, import it before applying rather than creating a duplicate. Applying this configuration without a running connector does not produce a working blog.

The connector will need its tunnel-specific token, not the account API token or login certificate. Do not commit credentials or print tunnel tokens in outputs. Any tunnel credentials later managed through OpenTofu must remain protected by the existing encrypted state and plan configuration.

## Requirements


- Homebrew: `opentofu`, `incus`, `just`, `docker-credential-helper`, `go`.
- `hujsonfmt`: `go install github.com/tailscale/hujson/cmd/hujsonfmt@latest`.
- Tailscale access to `hv01` and local Incus credentials.
- `.env` with Tailscale OAuth credentials, API keys, and the state passphrase.
- Local `terraform.tfstate`; keep state backups and the passphrase independent of the homelab.

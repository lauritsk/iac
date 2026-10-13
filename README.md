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

`blog.tofu` manages Caddy (`blog`), its read-only site volume, the Cloudflare connector (`blog-cf`), a remotely managed tunnel, and DNS for `blog.laurits.dev`. The tunnel connects to `http://blog.incus:8080`; no host port forwarding is needed. Caddy uses its image's default command and configuration path.

The Hugo source is in `blog/`, with no external theme dependency. Edit Markdown in `blog/content/`. `just blog-build` builds locally using the pinned Red Hat Hugo image; `just plan` and `just apply` also build before running OpenTofu. Generated `blog/public/` files are ignored by Git and uploaded through the storage volume resource. This initial workflow supports text assets only; binary images need a different upload mechanism.

Create a Cloudflare API token with **Cloudflare One Connector: cloudflared → Edit** for the account and **DNS → Edit** restricted to `laurits.dev`. Store it in the ignored local `.env`:

```dotenv
CLOUDFLARE_API_TOKEN=your-scoped-api-token
```

The account and zone IDs are fixed in `blog.tofu`. OpenTofu retrieves the tunnel-specific runtime token; the account API token and cloudflared login certificate are not deployed to the connector. Incus administrators can read the connector token from its configuration, so restrict administrative access. Site files and the runtime token are stored in the existing encrypted state.

Run `just plan` and review it before `just apply`. Import an existing `blog` tunnel or `blog.laurits.dev` DNS record before applying rather than creating a duplicate. Docker must be running for Hugo builds, and local registry credentials must allow pulls from `dhi.io`.

## Requirements


- Homebrew: `opentofu`, `incus`, `just`, `docker-credential-helper`, `go`.
- `hujsonfmt`: `go install github.com/tailscale/hujson/cmd/hujsonfmt@latest`.
- Tailscale access to `hv01` and local Incus credentials.
- `.env` with Tailscale OAuth credentials, API keys, and the state passphrase.
- Local `terraform.tfstate`; keep state backups and the passphrase independent of the homelab.

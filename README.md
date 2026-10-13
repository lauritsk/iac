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

## Requirements


- Homebrew: `opentofu`, `incus`, `just`, `docker-credential-helper`, `go`.
- `hujsonfmt`: `go install github.com/tailscale/hujson/cmd/hujsonfmt@latest`.
- Tailscale access to `hv01` and local Incus credentials.
- `.env` with Tailscale OAuth credentials, API keys, and the state passphrase.
- Local `terraform.tfstate`; keep state backups and the passphrase independent of the homelab.

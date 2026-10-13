# Homelab IaC

## Setup

- Homebrew: `opentofu`, `incus`, `just`, `docker-credential-helper`, `go`.
- `hujsonfmt`: `go install github.com/tailscale/hujson/cmd/hujsonfmt@latest`.
- Tailscale access to `hv01` and local Incus credentials.
- `.env`: Tailscale OAuth credentials, API keys, state passphrase, and `CLOUDFLARE_API_TOKEN`.
- Local `terraform.tfstate`; back up state, passphrase, and recovery keys outside the homelab. Never commit secrets.

```sh
just check
just plan
just apply
```

## Transmission

- TCP/UDP `51413`: RouterOS WAN → `10.1.10.8:51413` → container (`transmission.tofu`). No `9091` or IPv6 forwarding.
- Router `admin@10.1.10.1`: external-to-OpenTofu `dstnat` rules `Transmission peer tcp` / `Transmission peer udp`, matching WAN, local destination, port `51413`. Existing firewall permits destination NAT.
- Check: `curl -4 https://portcheck.transmissionbt.com/51413` (`1` = open).
- Close: disable both router rules; remove `incus_network_forward.transmission_peer` and apply.

## Blog

- `blog.laurits.dev` → Cloudflare Tunnel (`blog-cf`) → Caddy at `http://blog.incus:8080`; managed by `blog.tofu`.
- Edit `blog/content/`; `just blog-build` builds Hugo. Plan/apply also build. Docker and `dhi.io` pull credentials required.
- `blog/public/` is generated and ignored; uploads support text assets only.
- Cloudflare token: account **Cloudflare One Connector: cloudflared → Edit**, zone `laurits.dev` **DNS → Edit**. Account/zone IDs are in `blog.tofu`.
- Import existing tunnel/DNS resources before applying. Site files and runtime tunnel token are in encrypted state; Incus admins can read the connector token.

## IncusOS: hv01

Observed 2026-10-11; not managed by OpenTofu or a restore script.

| Area                | Configuration                                                                                                             |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Updates             | `stable`, every `6h`; Monday 04:00–05:00 `Europe/Tallinn`; automatic reboot                                               |
| Network             | `eno1`, MAC `1c:69:7a:62:b9:73`; DHCPv4 + SLAAC; hostname `hv01`, empty domain; `required_for_online: "no"`               |
| Ethernet            | EEE, GRO, GSO, IPv4/IPv6 TSO disabled; rationale unknown                                                                  |
| Time                | `Europe/Tallinn`; NTP `time.cloudflare.com`                                                                               |
| Host Tailscale      | Enabled; `accept_dns: true`; `accept_routes`, `advertise_exit_node`, `exit_node_allow_lan_access`, `serve_enabled`: false |
| Other services      | iSCSI, LVM, multipath, NetBird, NVMe, OVN, USB/IP disabled                                                                |
| Storage maintenance | Scrub `0 4 * * 0`; trim `0 4 * * 6`                                                                                       |
| Fallback listener   | `persistent: false`; one trusted certificate; retain client certificate/private key separately                            |
| Other               | Kernel config empty; no remote logging; provider `images`; Incus `lxcfs.cpu_shares` / `lxcfs.load_average`: false         |

| Pool    | Device                                                            | Type        | Alignment | IncusOS managed |
| ------- | ----------------------------------------------------------------- | ----------- | --------- | --------------- |
| `local` | `/dev/disk/by-id/nvme-KINGSTON_SNV2S500G_50026B76866B45E7-part11` | `zfs-raid0` | 4096      | Yes             |
| `fast`  | `/dev/disk/by-id/scsi-35000000000000001`                          | `zfs-raid0` | 4096      | Yes             |
| `slow`  | `/dev/disk/by-id/ata-WDC_WD160EDGZ-11CMYA0_PMGTZ1NP`              | `zfs-raid0` | 1         | No              |

`local`/`fast`: `incus` volume, use `incus`, no quota. `slow`: `containers`, `custom`, `deleted`, `images`, `virtual-machines`, `buckets`. Do not recreate or format existing pools.

Inspect with `incus admin os system <section> show hv01:` (`update`, `network`, `storage`, `fallback-listener`, `kernel`, `logging`, `provider`), `incus admin os service show hv01:tailscale`, or `incus admin os application show hv01:incus`.

`update check` can apply updates. Use the network edit/confirmation workflow for network changes. Never commit `system security show` output: it contains recovery material.

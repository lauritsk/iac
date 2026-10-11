# IncusOS host configuration

Live configuration on `hv01` that is not managed by this repository's OpenTofu resources. Recorded on 2026-10-11 using read-only `incus admin os` queries.

This is a configuration inventory, not an automatically applied configuration or a complete backup. Defaults can vary by IncusOS release, and installation seed data can override them. Where noted, defaults were compared with upstream `lxc/incus-os` `main`, not the exact installed release. Reasons for existing settings were not recorded; do not assume the network tuning is required without checking its history or testing.

Credentials, private keys, encryption recovery keys, and Tailscale identity state must remain outside Git.

## Updates

```yaml
config:
  auto_reboot: true
  channel: stable
  check_frequency: 6h
  maintenance_windows:
    - start_day_of_week: Monday
      start_hour: 4
      start_minute: 0
      end_day_of_week: Monday
      end_hour: 5
      end_minute: 0
```

Customizations relative to upstream defaults are automatic reboot and the Monday 04:00–05:00 maintenance window. `stable` and `6h` match upstream defaults. Maintenance windows use the host timezone below; update checks are skipped outside the window. Automatic reboot can interrupt all workloads on this host.

Inspect or edit:

```sh
incus admin os system update show hv01:
incus admin os system update edit hv01:
```

Do not use `update check` merely to inspect configuration: it can apply updates.

## Host network and time

```yaml
config:
  dns:
    domain: ""
    hostname: hv01
  interfaces:
    - addresses:
        - dhcp4
        - slaac
      ethernet:
        disable_energy_efficient: true
        disable_gro: true
        disable_gso: true
        disable_ipv4_tso: true
        disable_ipv6_tso: true
      hwaddr: "1c:69:7a:62:b9:73"
      name: eno1
      required_for_online: "no"
  time:
    ntp_servers:
      - time.cloudflare.com
    timezone: Europe/Tallinn
```

This describes the physical host interface, not the `incusbr0` instance bridge managed in `platform.tofu`.

Explicit host settings include the hostname, NTP server, timezone, disabled Ethernet energy saving/offloads, and opting `eno1` out of network-online readiness requirements. DHCPv4 and SLAAC are the current address acquisition modes; their presence alone does not establish a deviation from installation defaults.

The rationale for disabling EEE, GRO, GSO, and both TSO variants is unknown. These may be workarounds for NIC/driver problems, but disabling offloads can increase CPU overhead and reduce throughput. `required_for_online: "no"` allows boot to proceed without waiting for this interface to be ready. Preserve these settings until their purpose is established.

```sh
incus admin os system network show hv01:
```

Network changes require special care to avoid losing host access; use the IncusOS network edit/confirmation workflow rather than treating this snippet as an unattended restore script.

## Host Tailscale service

The IncusOS Tailscale service is enabled. This is separate from the per-application Tailscale gateway instances declared in OpenTofu.

Observed non-secret boolean settings:

```yaml
config:
  accept_dns: true
  accept_routes: false
  advertise_exit_node: false
  enabled: true
  exit_node_allow_lan_access: false
  serve_enabled: false
```

These are not a complete service configuration export. Authentication material and identity state are intentionally omitted. DNS acceptance lets Tailscale configure host DNS; check for dependencies on DNS services running on this host when troubleshooting boot or update connectivity.

```sh
incus admin os service show hv01:tailscale
```

The other available services are disabled: iSCSI, LVM, multipath, NetBird, NVMe, OVN, and USB/IP.

## Host storage

OpenTofu declares Incus storage pools and volumes, but does not describe the IncusOS backing-disk configuration below.

| Pool | Backing device | Type | Alignment | IncusOS managed |
| --- | --- | --- | --- | --- |
| `local` | `/dev/disk/by-id/nvme-KINGSTON_SNV2S500G_50026B76866B45E7-part11` | `zfs-raid0` | 4096 | Yes |
| `fast` | `/dev/disk/by-id/scsi-35000000000000001` | `zfs-raid0` | 4096 | Yes |
| `slow` | `/dev/disk/by-id/ata-WDC_WD160EDGZ-11CMYA0_PMGTZ1NP` | `zfs-raid0` | 1 | No |

`local` and `fast` each have an `incus` volume with use `incus` and no configured quota. The existing `slow` pool contains the datasets `containers`, `custom`, `deleted`, `images`, `virtual-machines`, and `buckets`; IncusOS reports their use as `-`. Do not recreate or format these pools from this inventory; the disk IDs are specific to this hardware and existing data must be retained.

Current maintenance schedules match upstream defaults:

```yaml
config:
  scrub_schedule: "0 4 * * 0"
  trim_schedule: "0 4 * * 6"
```

Scrub runs Sunday at 04:00; trim runs Saturday at 04:00.

```sh
incus admin os system storage show hv01:
```

## Fallback listener and recovery

The fallback listener has `persistent: false` and one trusted client certificate. Its SHA-256 fingerprint (DER certificate bytes) is:

```text
79f805530620164355b0241854a706dbf1a29bcc539a68df931e39639306e276
```

The certificate itself is not included here. Re-establishing access on a rebuilt host requires the appropriate trusted certificate and corresponding client private key; the fingerprint alone is not sufficient.

The security configuration contains one encryption recovery key entry. Its contents are intentionally not recorded. Keep recovery material securely backed up independently of the homelab and repository.

```sh
incus admin os system fallback-listener show hv01:
```

Avoid copying the output of `incus admin os system security show hv01:` into Git because it contains recovery material.

## Other inspected configuration

These sections had no additional active customization identified in the inspected fields:

- Kernel: empty configuration.
- Logging: no remote journal-upload URL or syslog address configured.
- Provider: `name: images`.
- Incus application: `lxcfs.cpu_shares: false` and `lxcfs.load_average: false`; recorded as current values, not verified deviations from defaults.

```sh
incus admin os system kernel show hv01:
incus admin os system logging show hv01:
incus admin os system provider show hv01:
incus admin os application show hv01:incus
```

## Checking defaults

`show` returns current host configuration, not factory defaults. Compare documentation and initialization code for the installed release when determining which values are custom:

- [System configuration reference](https://github.com/lxc/incus-os/tree/main/doc/reference/system)
- [Update configuration reference](https://github.com/lxc/incus-os/blob/main/doc/reference/system/update.md)
- [Default state initialization](https://github.com/lxc/incus-os/blob/main/incus-osd/internal/state/file.go), particularly `initialize()`.

Do not reset a production host just to inspect defaults.

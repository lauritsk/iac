# Transmission

resource "incus_storage_volume" "transmission_data" {
  remote      = "hv01"
  project     = "default"
  name        = "transmission-data"
  description = "Transmission configuration"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "transmission_watch" {
  remote      = "hv01"
  project     = "default"
  name        = "transmission-watch"
  description = "Transmission watch directory"
  pool        = "local"
}


resource "incus_instance" "transmission" {
  remote      = "hv01"
  project     = "default"
  name        = "transmission"
  image       = "oci-ghcr:linuxserver/transmission:4.1.3-r0-ls362@sha256:1a12fef3c89eca48b7be9e7d36b17b4eb4e1bcf5e1ee7fbf372e3a38b562939d"
  description = "Transmission"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID" = "1000"
    "environment.PGID" = "1000"
    "environment.TZ"   = "Europe/Tallinn"
    "environment.WHITELIST" = join(",", [
      "127.0.0.1",
      "::1",
      incus_instance.prowlarr.ipv4_address,
      incus_instance.prowlarr.ipv6_address,
      incus_instance.radarr.ipv4_address,
      incus_instance.radarr.ipv6_address,
      incus_instance.sonarr.ipv4_address,
      incus_instance.sonarr.ipv6_address,
      incus_instance.transmission_ts.ipv4_address,
      incus_instance.transmission_ts.ipv6_address,
    ])
    "environment.HOST_WHITELIST" = "transmission.cormo-tegu.ts.net,transmission.incus,transmission"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.transmission_data.pool
      "source" = incus_storage_volume.transmission_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "watch"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.transmission_watch.pool
      "source" = incus_storage_volume.transmission_watch.name
      "path"   = "/watch"
    }
  }

  device {
    name = "fast"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media_fast.pool
      "source" = incus_storage_volume.media_fast.name
      "path"   = "/data/fast"
    }
  }

}

resource "tailscale_oauth_client" "transmission" {
  description = "Transmission Tailscale gateway"
  scopes      = ["auth_keys"]
  tags        = ["tag:transmission"]

  depends_on = [tailscale_acl.policy]
}

resource "incus_storage_volume" "transmission_ts_state" {
  remote      = "hv01"
  project     = "default"
  name        = "transmission-ts-state"
  description = "Transmission Tailscale identity"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_volume" "transmission_ts_config" {
  remote      = "hv01"
  project     = "default"
  name        = "transmission-ts-config"
  description = "Transmission Tailscale Serve configuration"
  pool        = "local"

  file {
    content = jsonencode({
      TCP = {
        "443" = { HTTPS = true }
      }
      Web = {
        "$${TS_CERT_DOMAIN}:443" = {
          Handlers = {
            "/" = { Proxy = "http://transmission.incus:9091" }
          }
        }
      }
      AllowFunnel = {}
    })
    target_path = "/serve.json"
    mode        = "0644"
  }
}

resource "incus_instance" "transmission_ts" {
  remote      = "hv01"
  project     = "default"
  name        = "transmission-ts"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.5@sha256:c507f3a2a6ab1cabd8d809b98edeb41edbd5c3fb6ad9632ffd098b4c7d0b4065"
  description = "Transmission Tailscale HTTPS gateway"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_AUTHKEY"      = "${tailscale_oauth_client.transmission.key}?ephemeral=false"
    "environment.TS_AUTH_ONCE"    = "true"
    "environment.TS_HOSTNAME"     = "transmission"
    "environment.TS_EXTRA_ARGS"   = "--advertise-tags=tag:transmission"
    "environment.TS_ACCEPT_DNS"   = "false"
    "environment.TS_USERSPACE"    = "false"
    "environment.TS_STATE_DIR"    = "/var/lib/tailscale"
    "environment.TS_SERVE_CONFIG" = "/etc/tailscale/serve.json"
    "environment.TZ"              = "Europe/Tallinn"
  }

  device {
    name = "state"
    type = "disk"

    properties = {
      pool   = incus_storage_volume.transmission_ts_state.pool
      source = incus_storage_volume.transmission_ts_state.name
      path   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.transmission_ts_config.pool
      source   = incus_storage_volume.transmission_ts_config.name
      path     = "/etc/tailscale"
      readonly = "true"
    }
  }

  device {
    name = "tun"
    type = "unix-char"

    properties = {
      source = "/dev/net/tun"
      path   = "/dev/net/tun"
    }
  }

}

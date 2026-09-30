# Jellyfin

resource "incus_storage_volume" "jellyfin_cache" {
  remote      = "hv01"
  project     = local.project
  name        = "jellyfin-cache"
  description = "Jellyfin cache"
  pool        = local.root_pool
}


resource "incus_storage_volume" "jellyfin_config" {
  remote      = "hv01"
  project     = local.project
  name        = "jellyfin-config"
  description = "Jellyfin configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "jellyfin" {
  remote      = "hv01"
  project     = local.project
  name        = "jellyfin"
  image       = "oci-ghcr:jellyfin/jellyfin:12.1@sha256:008ec8024bdaaa6f0a3f0de468e185633eeba9d67c56936e8dbf5ef6b8d6200f"
  description = "Jellyfin"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "oci.uid"                                 = local.app_uid
    "oci.gid"                                 = local.app_gid
    "environment.TZ"                          = "Europe/Tallinn"
    "environment.JELLYFIN_PublishedServerUrl" = "https://jellyfin.${local.tailnet_domain}"
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.jellyfin_config.pool
      "source" = incus_storage_volume.jellyfin_config.name
      "path"   = "/config"
    }
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.jellyfin_cache.pool
      "source" = incus_storage_volume.jellyfin_cache.name
      "path"   = "/cache"
    }
  }

  device {
    name = "slow"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media_slow.pool
      "source" = incus_storage_volume.media_slow.name
      "path"   = "/data/slow"
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

  device {
    name = "gpu"
    type = "gpu"

    properties = {
      "mode" = "0666"
    }
  }
}

resource "tailscale_oauth_client" "jellyfin" {
  description = "Jellyfin Tailscale gateway"
  scopes      = ["auth_keys"]
  tags        = ["tag:jellyfin"]

  depends_on = [tailscale_acl.policy]
}

resource "incus_storage_volume" "jellyfin_ts_state" {
  remote      = "hv01"
  project     = local.project
  name        = "jellyfin-ts-state"
  description = "Jellyfin Tailscale identity"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_volume" "jellyfin_ts_config" {
  remote      = "hv01"
  project     = local.project
  name        = "jellyfin-ts-config"
  description = "Jellyfin Tailscale Serve configuration"
  pool        = local.root_pool

  file {
    content = jsonencode({
      TCP = {
        "443" = { HTTPS = true }
      }
      Web = {
        "$${TS_CERT_DOMAIN}:443" = {
          Handlers = {
            "/" = { Proxy = "http://jellyfin.incus:8096" }
          }
        }
      }
      AllowFunnel = {}
    })
    target_path = "/serve.json"
    mode        = "0644"
  }
}

resource "incus_instance" "jellyfin_ts" {
  remote      = "hv01"
  project     = local.project
  name        = "jellyfin-ts"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.5@sha256:c507f3a2a6ab1cabd8d809b98edeb41edbd5c3fb6ad9632ffd098b4c7d0b4065"
  description = "Jellyfin Tailscale HTTPS gateway"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_AUTHKEY"      = "${tailscale_oauth_client.jellyfin.key}?ephemeral=false"
    "environment.TS_AUTH_ONCE"    = "true"
    "environment.TS_HOSTNAME"     = "jellyfin"
    "environment.TS_EXTRA_ARGS"   = "--advertise-tags=tag:jellyfin"
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
      pool   = incus_storage_volume.jellyfin_ts_state.pool
      source = incus_storage_volume.jellyfin_ts_state.name
      path   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.jellyfin_ts_config.pool
      source   = incus_storage_volume.jellyfin_ts_config.name
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

  depends_on = [incus_instance.jellyfin]
}

# Zerobyte backup server

resource "incus_storage_volume" "zerobyte_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "zerobyte-data"
  description = "Zerobyte backup server data"
  pool        = incus_storage_pool.fast.name
  config = {
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "zerobyte_secret" {
  remote      = var.incus_remote
  project     = local.project
  name        = "zerobyte-secret"
  description = "Zerobyte application secrets"
  pool        = incus_storage_pool.fast.name

  file {
    content     = var.zerobyte_app_secret
    target_path = "/zerobyte_app_secret"
    uid         = 1000
    gid         = 1000
    mode        = "0400"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "zerobyte" {
  remote      = var.incus_remote
  project     = local.project
  name        = "zerobyte"
  image       = "oci-ghcr:nicotsx/zerobyte@sha256:08d1766977b28b3530054fc9df8b1a0ba3f7f9861c5367b03aa3e9ab71c2102f"
  description = "Zerobyte backup server"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ"                      = var.timezone
    "environment.BASE_URL"                = "https://zerobyte.${local.tailnet_domain}"
    "environment.TRUSTED_ORIGINS"         = "https://idp.${local.tailnet_domain}"
    "environment.APP_SECRET_FILE"         = "/run/secrets/zerobyte_app_secret"
    "environment.GOMAXPROCS"              = "2"
    "environment.WEBHOOK_TIMEOUT"         = "600"
    "environment.WEBHOOK_ALLOWED_ORIGINS" = "http://jellyfin:8096"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.zerobyte_data.name
      "path"   = "/var/lib/zerobyte"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.zerobyte_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

  device {
    name = "incus-backups"
    type = "disk"

    properties = {
      "pool"     = "local"
      "source"   = "backups"
      "path"     = "/mnt/src/incus-backups"
      "readonly" = "true"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.slow.name
      "source"   = incus_storage_volume.media.name
      "path"     = "/mnt/src/media"
      "readonly" = "true"
    }
  }

  device {
    name = "beszel-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.beszel_data.name
      "path"     = "/mnt/src/beszel"
      "readonly" = "true"
    }
  }

  device {
    name = "uptime-kuma-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.uptime_kuma_data.name
      "path"     = "/mnt/src/uptime-kuma"
      "readonly" = "true"
    }
  }

  device {
    name = "tailscale-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.tailscale_data.name
      "path"     = "/mnt/src/tailscale"
      "readonly" = "true"
    }
  }

  device {
    name = "beszel-agent-backup"
    type = "disk"

    properties = {
      "pool"     = "local"
      "source"   = incus_storage_volume.beszel_agent_data.name
      "path"     = "/mnt/src/beszel-agent"
      "readonly" = "true"
    }
  }

  device {
    name = "tsidp-backup"
    type = "disk"

    properties = {
      "pool"     = "local"
      "source"   = incus_storage_volume.tsidp_data.name
      "path"     = "/mnt/src/tsidp"
      "readonly" = "true"
    }
  }

  device {
    name = "jellyfin-config-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.jellyfin_config.name
      "path"     = "/mnt/src/jellyfin"
      "readonly" = "true"
    }
  }

  device {
    name = "prowlarr-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.prowlarr_data.name
      "path"     = "/mnt/src/prowlarr"
      "readonly" = "true"
    }
  }

  device {
    name = "radarr-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.radarr_data.name
      "path"     = "/mnt/src/radarr"
      "readonly" = "true"
    }
  }

  device {
    name = "recyclarr-secret-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.recyclarr_secret.name
      "path"     = "/mnt/src/recyclarr-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "sonarr-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.sonarr_data.name
      "path"     = "/mnt/src/sonarr"
      "readonly" = "true"
    }
  }

  device {
    name = "transmission-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.transmission_data.name
      "path"     = "/mnt/src/transmission"
      "readonly" = "true"
    }
  }

  device {
    name = "transmission-secret-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.transmission_secret.name
      "path"     = "/mnt/src/transmission-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "immich-db-secret-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.immich_db_secret.name
      "path"     = "/mnt/src/immich-db-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "immich-library-backup"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.immich_library.name
      "path"     = "/mnt/src/immich-library"
      "readonly" = "true"
    }
  }
}

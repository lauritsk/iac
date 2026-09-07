# Zerobyte backup server

resource "incus_storage_volume" "zerobyte_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "zerobyte-data"
  pool    = "fast"
  config = {
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
  }
}


resource "incus_storage_volume" "zerobyte_secret" {
  remote  = var.incus_remote
  project = "default"
  name    = "zerobyte-secret"
  pool    = "fast"

  file {
    content     = var.zerobyte_app_secret
    target_path = "/zerobyte_app_secret"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }
}


resource "incus_instance" "zerobyte" {
  remote      = var.incus_remote
  project     = "default"
  name        = "zerobyte"
  image       = "oci-ghcr:nicotsx/zerobyte:latest"
  description = "Zerobyte backup server"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.BASE_URL"                = "https://zerobyte.cormo-tegu.ts.net"
    "environment.TRUSTED_ORIGINS"         = "https://idp.cormo-tegu.ts.net"
    "environment.APP_SECRET_FILE"         = "/run/secrets/zerobyte_app_secret"
    "environment.GOMAXPROCS"              = "2"
    "environment.WEBHOOK_TIMEOUT"         = "600"
    "environment.WEBHOOK_ALLOWED_ORIGINS" = "http://jellyfin:8096"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.zerobyte_data.name
      "path"   = "/var/lib/zerobyte"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
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
      "pool"     = "slow"
      "source"   = incus_storage_volume.media.name
      "path"     = "/mnt/src/media"
      "readonly" = "true"
    }
  }

  device {
    name = "beszel-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.beszel_data.name
      "path"     = "/mnt/src/beszel"
      "readonly" = "true"
    }
  }

  device {
    name = "uptime-kuma-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.uptime_kuma_data.name
      "path"     = "/mnt/src/uptime-kuma"
      "readonly" = "true"
    }
  }

  device {
    name = "tailscale-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
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
      "pool"     = "fast"
      "source"   = incus_storage_volume.jellyfin_config.name
      "path"     = "/mnt/src/jellyfin"
      "readonly" = "true"
    }
  }

  device {
    name = "prowlarr-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.prowlarr_data.name
      "path"     = "/mnt/src/prowlarr"
      "readonly" = "true"
    }
  }

  device {
    name = "radarr-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.radarr_data.name
      "path"     = "/mnt/src/radarr"
      "readonly" = "true"
    }
  }

  device {
    name = "recyclarr-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.recyclarr_secret.name
      "path"     = "/mnt/src/recyclarr-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "sonarr-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.sonarr_data.name
      "path"     = "/mnt/src/sonarr"
      "readonly" = "true"
    }
  }

  device {
    name = "transmission-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.transmission_data.name
      "path"     = "/mnt/src/transmission"
      "readonly" = "true"
    }
  }

  device {
    name = "transmission-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.transmission_secret.name
      "path"     = "/mnt/src/transmission-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "immich-db-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.immich_db_secret.name
      "path"     = "/mnt/src/immich-db-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "immich-library-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.immich_library.name
      "path"     = "/mnt/src/immich-library"
      "readonly" = "true"
    }
  }

}

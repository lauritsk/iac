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

import {
  to = incus_storage_volume.zerobyte_data
  id = "${var.incus_remote}:default/fast/zerobyte-data"
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

import {
  to = incus_storage_volume.zerobyte_secret
  id = "${var.incus_remote}:default/fast/zerobyte-secret"
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
    "environment.BASE_URL"        = "https://zerobyte.cormo-tegu.ts.net"
    "environment.TRUSTED_ORIGINS" = "https://idp.cormo-tegu.ts.net"
    "environment.APP_SECRET_FILE" = "/run/secrets/zerobyte_app_secret"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "zerobyte-data"
      "path"   = "/var/lib/zerobyte"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "zerobyte-secret"
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"     = "slow"
      "source"   = "media"
      "path"     = "/mnt/src/media"
      "readonly" = "true"
    }
  }

  device {
    name = "beszel-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "beszel-data"
      "path"     = "/mnt/src/beszel"
      "readonly" = "true"
    }
  }

  device {
    name = "bichon-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "bichon-data"
      "path"     = "/mnt/src/bichon"
      "readonly" = "true"
    }
  }

  device {
    name = "uptime-kuma-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "uptime-kuma-data"
      "path"     = "/mnt/src/uptime-kuma"
      "readonly" = "true"
    }
  }

  device {
    name = "tailscale-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "tailscale-data"
      "path"     = "/mnt/src/tailscale"
      "readonly" = "true"
    }
  }

  device {
    name = "beszel-agent-backup"
    type = "disk"

    properties = {
      "pool"     = "local"
      "source"   = "beszel-agent-data"
      "path"     = "/mnt/src/beszel-agent"
      "readonly" = "true"
    }
  }

  device {
    name = "tsidp-backup"
    type = "disk"

    properties = {
      "pool"     = "local"
      "source"   = "tsidp-data"
      "path"     = "/mnt/src/tsidp"
      "readonly" = "true"
    }
  }

  device {
    name = "bichon-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "bichon-secret"
      "path"     = "/mnt/src/bichon-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "jellyfin-config-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "jellyfin-config"
      "path"     = "/mnt/src/jellyfin"
      "readonly" = "true"
    }
  }

  device {
    name = "prowlarr-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "prowlarr-data"
      "path"     = "/mnt/src/prowlarr"
      "readonly" = "true"
    }
  }

  device {
    name = "radarr-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "radarr-data"
      "path"     = "/mnt/src/radarr"
      "readonly" = "true"
    }
  }

  device {
    name = "recyclarr-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "recyclarr-secret"
      "path"     = "/mnt/src/recyclarr-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "sonarr-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "sonarr-data"
      "path"     = "/mnt/src/sonarr"
      "readonly" = "true"
    }
  }

  device {
    name = "transmission-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "transmission-data"
      "path"     = "/mnt/src/transmission"
      "readonly" = "true"
    }
  }

  device {
    name = "transmission-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "transmission-secret"
      "path"     = "/mnt/src/transmission-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "immich-db-secret-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "immich-db-secret"
      "path"     = "/mnt/src/immich-db-secret"
      "readonly" = "true"
    }
  }

  device {
    name = "immich-library-backup"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "immich-library"
      "path"     = "/mnt/src/immich-library"
      "readonly" = "true"
    }
  }

  depends_on = [
    incus_storage_volume.zerobyte_data,
    incus_storage_volume.zerobyte_secret,
    incus_storage_volume.media,
    incus_storage_volume.beszel_data,
    incus_storage_volume.bichon_data,
    incus_storage_volume.uptime_kuma_data,
    incus_storage_volume.tailscale_data,
    incus_storage_volume.beszel_agent_data,
    incus_storage_volume.tsidp_data,
    incus_storage_volume.bichon_secret,
    incus_storage_volume.jellyfin_config,
    incus_storage_volume.prowlarr_data,
    incus_storage_volume.radarr_data,
    incus_storage_volume.recyclarr_secret,
    incus_storage_volume.sonarr_data,
    incus_storage_volume.transmission_data,
    incus_storage_volume.transmission_secret,
    incus_storage_volume.immich_db_secret,
    incus_storage_volume.immich_library,
  ]
}

import {
  to = incus_instance.zerobyte
  id = "${var.incus_remote}:default/zerobyte,image=oci-ghcr:nicotsx/zerobyte:latest"
}

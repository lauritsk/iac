# Radarr

resource "incus_storage_volume" "radarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "radarr-data"
  description = "Radarr configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "radarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "radarr"
  image       = "oci-lscr:linuxserver/radarr@sha256:119aaa4a4f7349bcd2a136c5373a0d7925b5479915c7dfe0c0ad352db2a6d438"
  description = "Radarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                       = local.app_uid
    "environment.PGID"                       = local.app_gid
    "environment.TZ"                         = var.timezone
    "environment.FILE__RADARR__AUTH__APIKEY" = "/run/secrets/radarr_api_key"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.radarr_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.slow.name
      "source" = incus_storage_volume.media.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.recyclarr_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }
}

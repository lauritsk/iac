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
  image       = "oci-lscr:linuxserver/radarr:6.3.0.10514-ls315@sha256:95ba0801df4d9d1d79d0d9a3849f656542497dab061d91b87ad4f53a71aff3ef"
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

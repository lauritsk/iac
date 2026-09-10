# Sonarr

resource "incus_storage_volume" "sonarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "sonarr-data"
  description = "Sonarr configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "sonarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "sonarr"
  image       = "oci-lscr:linuxserver/sonarr:4.0.19.2979-ls323@sha256:4d9df314875e1249ab7d6170c2b9b3dc1d8e6383f168ceb10dc9a5ad9b324739"
  description = "Sonarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                       = local.app_uid
    "environment.PGID"                       = local.app_gid
    "environment.TZ"                         = var.timezone
    "environment.FILE__SONARR__AUTH__APIKEY" = "/run/secrets/sonarr_api_key"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.sonarr_data.pool
      "source" = incus_storage_volume.sonarr_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media.pool
      "source" = incus_storage_volume.media.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.recyclarr_secret.pool
      "source"   = incus_storage_volume.recyclarr_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }
}

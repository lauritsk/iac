# Sonarr

resource "incus_storage_volume" "sonarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "sonarr-data"
  description = "Sonarr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "sonarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "sonarr"
  image       = "oci-ghcr:linuxserver/sonarr:4.0.20.3014-ls325@sha256:a5c1a5fecbef946927ab90ad68df319ac5fe644057e5fc18cd993f01ac07b2b2"
  description = "Sonarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                 = local.app_uid
    "environment.PGID"                 = local.app_gid
    "environment.TZ"                   = var.timezone
    "environment.SONARR__AUTH__APIKEY" = var.sonarr_api_key
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

}

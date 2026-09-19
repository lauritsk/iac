# Radarr

resource "incus_storage_volume" "radarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "radarr-data"
  description = "Radarr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "radarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "radarr"
  image       = "oci-lscr:linuxserver/radarr:6.4.4.10685-ls317@sha256:c960f2b52ec6542dbe6707c5a21e696a7c74fd8b17997454f4d10a55dacee133"
  description = "Radarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                 = local.app_uid
    "environment.PGID"                 = local.app_gid
    "environment.TZ"                   = var.timezone
    "environment.RADARR__AUTH__APIKEY" = var.radarr_api_key
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.radarr_data.pool
      "source" = incus_storage_volume.radarr_data.name
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

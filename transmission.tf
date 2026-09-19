# Transmission

resource "incus_storage_volume" "transmission_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-data"
  description = "Transmission configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "transmission_watch" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-watch"
  description = "Transmission watch directory"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "transmission" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission"
  image       = "oci-ghcr:linuxserver/transmission:4.1.3-r0-ls362@sha256:1a12fef3c89eca48b7be9e7d36b17b4eb4e1bcf5e1ee7fbf372e3a38b562939d"
  description = "Transmission"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID" = local.app_uid
    "environment.PGID" = local.app_gid
    "environment.TZ"   = var.timezone
    "environment.USER" = var.transmission_username
    "environment.PASS" = var.transmission_password
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

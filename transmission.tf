# Transmission

resource "incus_storage_volume" "transmission_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-data"
  description = "Transmission configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "transmission_watch" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-watch"
  description = "Transmission watch directory"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "transmission" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission"
  image       = "oci-lscr:linuxserver/transmission:4.1.3-r0-ls361@sha256:fc3b07f2f571c0392edd4dd386067138a0fe157d2158a976769409a292e43936"
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
    name = "media"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media.pool
      "source" = incus_storage_volume.media.name
      "path"   = "/data"
    }
  }

}

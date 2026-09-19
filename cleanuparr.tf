# Cleanuparr

resource "incus_storage_volume" "cleanuparr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "cleanuparr-data"
  description = "Cleanuparr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "cleanuparr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "cleanuparr"
  image       = "oci-ghcr:cleanuparr/cleanuparr:2.10.6@sha256:8136c3beda7aa217012657e0ee31f0473ff4ae7e54a156730ff04523987fa815"
  description = "Download manager for the Servarr stack"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID" = local.app_uid
    "environment.PGID" = local.app_gid
    "environment.TZ"   = var.timezone
    "environment.PORT" = "11011"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.cleanuparr_data.pool
      "source" = incus_storage_volume.cleanuparr_data.name
      "path"   = "/config"
    }
  }
}

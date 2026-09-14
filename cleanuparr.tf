# Cleanuparr

resource "incus_storage_volume" "cleanuparr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "cleanuparr-data"
  description = "Cleanuparr configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "cleanuparr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "cleanuparr"
  image       = "oci-ghcr:cleanuparr/cleanuparr:2.10.2@sha256:98463b1116142887767cf90dde3375e7e43718aa623fe737677372023ffb7ebe"
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

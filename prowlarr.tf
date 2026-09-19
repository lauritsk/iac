# Prowlarr

resource "incus_storage_volume" "prowlarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "prowlarr-data"
  description = "Prowlarr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "prowlarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "prowlarr"
  image       = "oci-lscr:linuxserver/prowlarr:2.6.5.5623-ls161@sha256:c96b56d94d116a9f4de94bc23d3381689492e6c3cfb7435320e8d982e406f99a"
  description = "Prowlarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                   = local.app_uid
    "environment.PGID"                   = local.app_gid
    "environment.TZ"                     = var.timezone
    "environment.PROWLARR__AUTH__APIKEY" = var.prowlarr_api_key
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.prowlarr_data.pool
      "source" = incus_storage_volume.prowlarr_data.name
      "path"   = "/config"
    }
  }

}

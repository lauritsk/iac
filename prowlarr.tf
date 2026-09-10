# Prowlarr

resource "incus_storage_volume" "prowlarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "prowlarr-data"
  description = "Prowlarr configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "prowlarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "prowlarr"
  image       = "oci-lscr:linuxserver/prowlarr:2.5.2.5491-ls159@sha256:c7502a75b021d964481c129c84590b9cbc40f83aadd4e553f173871bc0deaa3c"
  description = "Prowlarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                         = local.app_uid
    "environment.PGID"                         = local.app_gid
    "environment.TZ"                           = var.timezone
    "environment.FILE__PROWLARR__AUTH__APIKEY" = "/run/secrets/prowlarr_api_key"
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

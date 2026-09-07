# Prowlarr

resource "incus_storage_volume" "prowlarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "prowlarr-data"
  pool    = "fast"
}


resource "incus_instance" "prowlarr" {
  remote      = var.incus_remote
  project     = "default"
  name        = "prowlarr"
  image       = "oci-lscr:linuxserver/prowlarr:latest"
  description = "Prowlarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                         = "1000"
    "environment.PGID"                         = "1000"
    "environment.TZ"                           = var.timezone
    "environment.FILE__PROWLARR__AUTH__APIKEY" = "/run/secrets/prowlarr_api_key"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.prowlarr_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.recyclarr_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

}

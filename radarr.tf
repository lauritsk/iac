# Radarr

resource "incus_storage_volume" "radarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "radarr-data"
  pool    = "fast"
}


resource "incus_instance" "radarr" {
  remote      = var.incus_remote
  project     = "default"
  name        = "radarr"
  image       = "oci-lscr:linuxserver/radarr:latest"
  description = "Radarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.FILE__RADARR__AUTH__APIKEY" = "/run/secrets/radarr_api_key"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.radarr_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = "slow"
      "source" = incus_storage_volume.media.name
      "path"   = "/data"
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

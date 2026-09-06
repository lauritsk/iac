# Sonarr

resource "incus_storage_volume" "sonarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "sonarr-data"
  pool    = "fast"
}


resource "incus_instance" "sonarr" {
  remote      = var.incus_remote
  project     = "default"
  name        = "sonarr"
  image       = "oci-lscr:linuxserver/sonarr:latest"
  description = "Sonarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.FILE__SONARR__AUTH__APIKEY" = "/run/secrets/sonarr_api_key"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.sonarr_data.name
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

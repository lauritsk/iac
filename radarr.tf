# Radarr

resource "incus_storage_volume" "radarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "radarr-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.radarr_data
  id = "${var.incus_remote}:default/fast/radarr-data"
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
      "source" = "radarr-data"
      "path"   = "/config"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = "slow"
      "source" = "media"
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "recyclarr-secret"
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

  depends_on = [
    incus_storage_volume.radarr_data,
    incus_storage_volume.media,
    incus_storage_volume.recyclarr_secret,
  ]
}

import {
  to = incus_instance.radarr
  id = "${var.incus_remote}:default/radarr,image=oci-lscr:linuxserver/radarr:latest"
}

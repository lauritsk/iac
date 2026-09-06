# Prowlarr

resource "incus_storage_volume" "prowlarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "prowlarr-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.prowlarr_data
  id = "${var.incus_remote}:default/fast/prowlarr-data"
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
    "environment.FILE__PROWLARR__AUTH__APIKEY" = "/run/secrets/prowlarr_api_key"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "prowlarr-data"
      "path"   = "/config"
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
    incus_storage_volume.prowlarr_data,
    incus_storage_volume.recyclarr_secret,
  ]
}

import {
  to = incus_instance.prowlarr
  id = "${var.incus_remote}:default/prowlarr,image=oci-lscr:linuxserver/prowlarr:latest"
}

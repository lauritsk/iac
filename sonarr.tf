# Sonarr

resource "incus_storage_volume" "sonarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "sonarr-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.sonarr_data
  id = "${var.incus_remote}:default/fast/sonarr-data"
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
      "source" = "sonarr-data"
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
    incus_storage_volume.sonarr_data,
    incus_storage_volume.media,
    incus_storage_volume.recyclarr_secret,
  ]
}

import {
  to = incus_instance.sonarr
  id = "${var.incus_remote}:default/sonarr,image=oci-lscr:linuxserver/sonarr:latest"
}

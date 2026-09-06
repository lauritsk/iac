# Recyclarr

resource "incus_storage_volume" "recyclarr_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "recyclarr-data"
  pool    = "fast"

  file {
    source_path = "${path.module}/recyclarr.yml"
    target_path = "/recyclarr.yml"
    uid         = 0
    gid         = 0
    mode        = "0444"
  }
}

import {
  to = incus_storage_volume.recyclarr_data
  id = "${var.incus_remote}:default/fast/recyclarr-data"
}

resource "incus_storage_volume" "recyclarr_secret" {
  remote  = var.incus_remote
  project = "default"
  name    = "recyclarr-secret"
  pool    = "fast"

  file {
    content     = var.prowlarr_api_key
    target_path = "/prowlarr_api_key"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }

  file {
    content     = var.radarr_api_key
    target_path = "/radarr_api_key"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }

  file {
    content     = var.sonarr_api_key
    target_path = "/sonarr_api_key"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }
}

import {
  to = incus_storage_volume.recyclarr_secret
  id = "${var.incus_remote}:default/fast/recyclarr-secret"
}

resource "incus_instance" "recyclarr" {
  remote      = var.incus_remote
  project     = "default"
  name        = "recyclarr"
  image       = "oci-ghcr:recyclarr/recyclarr:latest"
  description = "Recyclarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.CRON_SCHEDULE" = "0 4 * * *"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "recyclarr-data"
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
    incus_storage_volume.recyclarr_data,
    incus_storage_volume.recyclarr_secret,
  ]
}

import {
  to = incus_instance.recyclarr
  id = "${var.incus_remote}:default/recyclarr,image=oci-ghcr:recyclarr/recyclarr:latest"
}

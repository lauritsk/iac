# Jellyfin

resource "incus_storage_volume" "jellyfin_cache" {
  remote  = var.incus_remote
  project = "default"
  name    = "jellyfin-cache"
  pool    = "fast"
}

import {
  to = incus_storage_volume.jellyfin_cache
  id = "${var.incus_remote}:default/fast/jellyfin-cache"
}

resource "incus_storage_volume" "jellyfin_config" {
  remote  = var.incus_remote
  project = "default"
  name    = "jellyfin-config"
  pool    = "fast"
}

import {
  to = incus_storage_volume.jellyfin_config
  id = "${var.incus_remote}:default/fast/jellyfin-config"
}

resource "incus_instance" "jellyfin" {
  remote      = var.incus_remote
  project     = "default"
  name        = "jellyfin"
  image       = "oci-ghcr:jellyfin/jellyfin:latest"
  description = "Jellyfin"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.JELLYFIN_PublishedServerUrl" = "https://jellyfin.cormo-tegu.ts.net"
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "jellyfin-config"
      "path"   = "/config"
    }
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "jellyfin-cache"
      "path"   = "/cache"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = "slow"
      "source" = "media"
      "path"   = "/media"
    }
  }

  device {
    name = "gpu"
    type = "gpu"

    properties = {
      "mode" = "0666"
    }
  }

  depends_on = [
    incus_storage_volume.jellyfin_config,
    incus_storage_volume.jellyfin_cache,
    incus_storage_volume.media,
  ]
}

import {
  to = incus_instance.jellyfin
  id = "${var.incus_remote}:default/jellyfin,image=oci-ghcr:jellyfin/jellyfin:latest"
}

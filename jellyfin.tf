# Jellyfin

resource "incus_storage_volume" "jellyfin_cache" {
  remote      = var.incus_remote
  project     = local.project
  name        = "jellyfin-cache"
  description = "Jellyfin cache"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "jellyfin_config" {
  remote      = var.incus_remote
  project     = local.project
  name        = "jellyfin-config"
  description = "Jellyfin configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "jellyfin" {
  remote      = var.incus_remote
  project     = local.project
  name        = "jellyfin"
  image       = "oci-ghcr:jellyfin/jellyfin@sha256:45f648c382a0c8b552582fcea40e95cb17c5d475473a891cba0eb7523fb92112"
  description = "Jellyfin"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ"                          = var.timezone
    "environment.JELLYFIN_PublishedServerUrl" = "https://jellyfin.${local.tailnet_domain}"
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.jellyfin_config.name
      "path"   = "/config"
    }
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.jellyfin_cache.name
      "path"   = "/cache"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.slow.name
      "source" = incus_storage_volume.media.name
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
}

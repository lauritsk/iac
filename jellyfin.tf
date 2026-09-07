# Jellyfin

resource "incus_storage_volume" "jellyfin_cache" {
  remote  = var.incus_remote
  project = "default"
  name    = "jellyfin-cache"
  pool    = "fast"
}


resource "incus_storage_volume" "jellyfin_config" {
  remote  = var.incus_remote
  project = "default"
  name    = "jellyfin-config"
  pool    = "fast"
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
    "environment.TZ"                          = var.timezone
    "environment.JELLYFIN_PublishedServerUrl" = "https://jellyfin.cormo-tegu.ts.net"
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.jellyfin_config.name
      "path"   = "/config"
    }
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.jellyfin_cache.name
      "path"   = "/cache"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = "slow"
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

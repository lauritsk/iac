# Jellyfin

resource "incus_storage_volume" "jellyfin_cache" {
  remote      = var.incus_remote
  project     = local.project
  name        = "jellyfin-cache"
  description = "Jellyfin cache"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "jellyfin_config" {
  remote      = var.incus_remote
  project     = local.project
  name        = "jellyfin-config"
  description = "Jellyfin configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "jellyfin" {
  remote      = var.incus_remote
  project     = local.project
  name        = "jellyfin"
  image       = "oci-ghcr:jellyfin/jellyfin:12.1@sha256:008ec8024bdaaa6f0a3f0de468e185633eeba9d67c56936e8dbf5ef6b8d6200f"
  description = "Jellyfin"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    # Live /config/config/system.xml: EnableLegacyAuthorization=true for Sonarr/Radarr.
    # Revisit and disable after both support modern Jellyfin authorization; verify library updates.
    "oci.uid"                                 = local.app_uid
    "oci.gid"                                 = local.app_gid
    "environment.TZ"                          = var.timezone
    "environment.JELLYFIN_PublishedServerUrl" = "https://jellyfin.${local.tailnet_domain}"
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.jellyfin_config.pool
      "source" = incus_storage_volume.jellyfin_config.name
      "path"   = "/config"
    }
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.jellyfin_cache.pool
      "source" = incus_storage_volume.jellyfin_cache.name
      "path"   = "/cache"
    }
  }

  device {
    name = "slow"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media_slow.pool
      "source" = incus_storage_volume.media_slow.name
      "path"   = "/data/slow"
    }
  }

  device {
    name = "fast"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media_fast.pool
      "source" = incus_storage_volume.media_fast.name
      "path"   = "/data/fast"
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

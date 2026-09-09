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
  image       = "oci-ghcr:jellyfin/jellyfin@sha256:74f4d87d9cf262c52d62be6be265c0355c6a7e21d0477ab6c654a49a4f8b1fd4"
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

# Unpackerr

resource "incus_instance" "unpackerr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "unpackerr"
  image       = "oci-ghcr:unpackerr/unpackerr:0.16.1@sha256:406586865431b40b29353d899fb75a788f5384743f7f381444db5fe55d206914"
  description = "Extract completed downloads for Radarr and Sonarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ"                  = var.timezone
    "environment.UN_RADARR_0_URL"     = local.service_backends.radarr
    "environment.UN_RADARR_0_API_KEY" = var.radarr_api_key
    "environment.UN_RADARR_0_PATHS_0" = "/data/fast/downloads"
    "environment.UN_SONARR_0_URL"     = local.service_backends.sonarr
    "environment.UN_SONARR_0_API_KEY" = var.sonarr_api_key
    "environment.UN_SONARR_0_PATHS_0" = "/data/fast/downloads"
    "oci.uid"                         = local.app_uid
    "oci.gid"                         = local.app_gid
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
}

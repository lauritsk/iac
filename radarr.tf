# Radarr

resource "incus_storage_volume" "radarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "radarr-data"
  description = "Radarr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "radarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "radarr"
  image       = "oci-ghcr:linuxserver/radarr:6.4.4.10685-ls318@sha256:adb6c09d6b729ea5e642c99cea35af72702ef476bf4763f153299ac5db9f0b4f"
  description = "Radarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                                = local.app_uid
    "environment.PGID"                                = local.app_gid
    "environment.TZ"                                  = var.timezone
    "environment.RADARR__APP__INSTANCENAME"           = "Radarr"
    "environment.RADARR__APP__LAUNCHBROWSER"          = "false"
    "environment.RADARR__APP__THEME"                  = "auto"
    "environment.RADARR__AUTH__APIKEY"                = var.radarr_api_key
    "environment.RADARR__AUTH__ENABLED"               = "false"
    "environment.RADARR__AUTH__METHOD"                = "Forms"
    "environment.RADARR__AUTH__REQUIRED"              = "Enabled"
    "environment.RADARR__AUTH__TRUSTCGNATIPADDRESSES" = "false"
    "environment.RADARR__LOG__ANALYTICSENABLED"       = "true"
    "environment.RADARR__LOG__DBENABLED"              = "true"
    "environment.RADARR__LOG__FILTERSENTRYEVENTS"     = "true"
    "environment.RADARR__LOG__LEVEL"                  = "debug"
    "environment.RADARR__LOG__ROTATE"                 = "50"
    "environment.RADARR__LOG__SIZELIMIT"              = "1"
    "environment.RADARR__LOG__SQL"                    = "false"
    "environment.RADARR__SERVER__ALLOWEDHOSTS"        = "radarr.${local.tailnet_domain},radarr.incus"
    "environment.RADARR__SERVER__BINDADDRESS"         = "*"
    "environment.RADARR__SERVER__ENABLESSL"           = "false"
    "environment.RADARR__SERVER__PORT"                = "7878"
    "environment.RADARR__SERVER__TRUSTEDNETWORKS"     = "${incus_instance.proxy.ipv4_address},${incus_instance.proxy.ipv6_address}"
    "environment.RADARR__UPDATE__AUTOMATICALLY"       = "false"
    "environment.RADARR__UPDATE__BRANCH"              = "master"
    "environment.RADARR__UPDATE__MECHANISM"           = "Docker"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.radarr_data.pool
      "source" = incus_storage_volume.radarr_data.name
      "path"   = "/config"
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

}

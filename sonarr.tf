# Sonarr

resource "incus_storage_volume" "sonarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "sonarr-data"
  description = "Sonarr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "sonarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "sonarr"
  image       = "oci-ghcr:linuxserver/sonarr:4.0.20.3014-ls325@sha256:a5c1a5fecbef946927ab90ad68df319ac5fe644057e5fc18cd993f01ac07b2b2"
  description = "Sonarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                                = local.app_uid
    "environment.PGID"                                = local.app_gid
    "environment.TZ"                                  = var.timezone
    "environment.SONARR__APP__INSTANCENAME"           = "Sonarr"
    "environment.SONARR__APP__LAUNCHBROWSER"          = "false"
    "environment.SONARR__APP__THEME"                  = "auto"
    "environment.SONARR__AUTH__APIKEY"                = var.sonarr_api_key
    "environment.SONARR__AUTH__ENABLED"               = "false"
    "environment.SONARR__AUTH__METHOD"                = "Forms"
    "environment.SONARR__AUTH__REQUIRED"              = "Enabled"
    "environment.SONARR__AUTH__TRUSTCGNATIPADDRESSES" = "false"
    "environment.SONARR__LOG__ANALYTICSENABLED"       = "true"
    "environment.SONARR__LOG__DBENABLED"              = "true"
    "environment.SONARR__LOG__FILTERSENTRYEVENTS"     = "true"
    "environment.SONARR__LOG__LEVEL"                  = "debug"
    "environment.SONARR__LOG__ROTATE"                 = "50"
    "environment.SONARR__LOG__SIZELIMIT"              = "1"
    "environment.SONARR__LOG__SQL"                    = "false"
    "environment.SONARR__SERVER__ALLOWEDHOSTS"        = "sonarr.${local.tailnet_domain},sonarr.incus"
    "environment.SONARR__SERVER__BINDADDRESS"         = "*"
    "environment.SONARR__SERVER__ENABLESSL"           = "false"
    "environment.SONARR__SERVER__PORT"                = "8989"
    "environment.SONARR__SERVER__TRUSTEDNETWORKS"     = "${incus_instance.proxy.ipv4_address},${incus_instance.proxy.ipv6_address}"
    "environment.SONARR__UPDATE__AUTOMATICALLY"       = "false"
    "environment.SONARR__UPDATE__BRANCH"              = "main"
    "environment.SONARR__UPDATE__MECHANISM"           = "Docker"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.sonarr_data.pool
      "source" = incus_storage_volume.sonarr_data.name
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

# Prowlarr

resource "incus_storage_volume" "prowlarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "prowlarr-data"
  description = "Prowlarr configuration"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "prowlarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "prowlarr"
  image       = "oci-ghcr:linuxserver/prowlarr:2.6.5.5623-ls162@sha256:f2b26429893d4c4cb71941b7ee50b1bdecd9d5f9f9e02d5410615e9f4f7c8d95"
  description = "Prowlarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                                  = local.app_uid
    "environment.PGID"                                  = local.app_gid
    "environment.TZ"                                    = var.timezone
    "environment.PROWLARR__APP__INSTANCENAME"           = "Prowlarr"
    "environment.PROWLARR__APP__LAUNCHBROWSER"          = "false"
    "environment.PROWLARR__APP__THEME"                  = "auto"
    "environment.PROWLARR__AUTH__APIKEY"                = var.prowlarr_api_key
    "environment.PROWLARR__AUTH__ENABLED"               = "false"
    "environment.PROWLARR__AUTH__METHOD"                = "Forms"
    "environment.PROWLARR__AUTH__REQUIRED"              = "Enabled"
    "environment.PROWLARR__AUTH__TRUSTCGNATIPADDRESSES" = "false"
    "environment.PROWLARR__LOG__ANALYTICSENABLED"       = "true"
    "environment.PROWLARR__LOG__DBENABLED"              = "true"
    "environment.PROWLARR__LOG__FILTERSENTRYEVENTS"     = "true"
    "environment.PROWLARR__LOG__LEVEL"                  = "debug"
    "environment.PROWLARR__LOG__ROTATE"                 = "50"
    "environment.PROWLARR__LOG__SIZELIMIT"              = "1"
    "environment.PROWLARR__LOG__SQL"                    = "false"
    "environment.PROWLARR__SERVER__ALLOWEDHOSTS"        = "prowlarr.${local.tailnet_domain},prowlarr.incus"
    "environment.PROWLARR__SERVER__BINDADDRESS"         = "*"
    "environment.PROWLARR__SERVER__ENABLESSL"           = "false"
    "environment.PROWLARR__SERVER__PORT"                = "9696"
    "environment.PROWLARR__SERVER__TRUSTEDNETWORKS"     = "${incus_instance.proxy.ipv4_address},${incus_instance.proxy.ipv6_address}"
    "environment.PROWLARR__UPDATE__AUTOMATICALLY"       = "false"
    "environment.PROWLARR__UPDATE__BRANCH"              = "master"
    "environment.PROWLARR__UPDATE__MECHANISM"           = "Docker"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.prowlarr_data.pool
      "source" = incus_storage_volume.prowlarr_data.name
      "path"   = "/config"
    }
  }

}

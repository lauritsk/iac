# Prowlarr

resource "incus_storage_volume" "prowlarr_data" {
  remote      = "hv01"
  project     = "default"
  name        = "prowlarr-data"
  description = "Prowlarr configuration"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "prowlarr" {
  remote      = "hv01"
  project     = "default"
  name        = "prowlarr"
  image       = "oci-ghcr:linuxserver/prowlarr:2.6.5.5623-ls162@sha256:f2b26429893d4c4cb71941b7ee50b1bdecd9d5f9f9e02d5410615e9f4f7c8d95"
  description = "Prowlarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                                  = "1000"
    "environment.PGID"                                  = "1000"
    "environment.TZ"                                    = "Europe/Tallinn"
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
    "environment.PROWLARR__SERVER__ALLOWEDHOSTS"        = "prowlarr.cormo-tegu.ts.net,prowlarr.incus"
    "environment.PROWLARR__SERVER__BINDADDRESS"         = "*"
    "environment.PROWLARR__SERVER__ENABLESSL"           = "false"
    "environment.PROWLARR__SERVER__PORT"                = "9696"
    "environment.PROWLARR__SERVER__TRUSTEDNETWORKS"     = "${incus_instance.prowlarr_ts.ipv4_address},${incus_instance.prowlarr_ts.ipv6_address}"
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

resource "tailscale_oauth_client" "prowlarr" {
  description = "Prowlarr Tailscale gateway"
  scopes      = ["auth_keys"]
  tags        = ["tag:prowlarr"]

  depends_on = [tailscale_acl.policy]
}

resource "incus_storage_volume" "prowlarr_ts_state" {
  remote      = "hv01"
  project     = "default"
  name        = "prowlarr-ts-state"
  description = "Prowlarr Tailscale identity"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_volume" "prowlarr_ts_config" {
  remote      = "hv01"
  project     = "default"
  name        = "prowlarr-ts-config"
  description = "Prowlarr Tailscale Serve configuration"
  pool        = "local"

  file {
    content = jsonencode({
      TCP = {
        "443" = { HTTPS = true }
      }
      Web = {
        "$${TS_CERT_DOMAIN}:443" = {
          Handlers = {
            "/" = { Proxy = "http://prowlarr.incus:9696" }
          }
        }
      }
      AllowFunnel = {}
    })
    target_path = "/serve.json"
    mode        = "0644"
  }
}

resource "incus_instance" "prowlarr_ts" {
  remote      = "hv01"
  project     = "default"
  name        = "prowlarr-ts"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.5@sha256:c507f3a2a6ab1cabd8d809b98edeb41edbd5c3fb6ad9632ffd098b4c7d0b4065"
  description = "Prowlarr Tailscale HTTPS gateway"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_AUTHKEY"      = "${tailscale_oauth_client.prowlarr.key}?ephemeral=false"
    "environment.TS_AUTH_ONCE"    = "true"
    "environment.TS_HOSTNAME"     = "prowlarr"
    "environment.TS_EXTRA_ARGS"   = "--advertise-tags=tag:prowlarr"
    "environment.TS_ACCEPT_DNS"   = "false"
    "environment.TS_USERSPACE"    = "false"
    "environment.TS_STATE_DIR"    = "/var/lib/tailscale"
    "environment.TS_SERVE_CONFIG" = "/etc/tailscale/serve.json"
    "environment.TZ"              = "Europe/Tallinn"
  }

  device {
    name = "state"
    type = "disk"

    properties = {
      pool   = incus_storage_volume.prowlarr_ts_state.pool
      source = incus_storage_volume.prowlarr_ts_state.name
      path   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.prowlarr_ts_config.pool
      source   = incus_storage_volume.prowlarr_ts_config.name
      path     = "/etc/tailscale"
      readonly = "true"
    }
  }

  device {
    name = "tun"
    type = "unix-char"

    properties = {
      source = "/dev/net/tun"
      path   = "/dev/net/tun"
    }
  }

}

variable "prowlarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

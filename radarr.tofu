# Radarr

resource "incus_storage_volume" "radarr_data" {
  remote      = "hv01"
  project     = "default"
  name        = "radarr-data"
  description = "Radarr configuration"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "radarr" {
  remote      = "hv01"
  project     = "default"
  name        = "radarr"
  image       = "oci-ghcr:linuxserver/radarr:6.4.4.10685-ls319@sha256:7dfd049e79c00b16fbc29c3f5d96a9e7b9e73a23930b4c5b3c4541d60b366814"
  description = "Radarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                                = "1000"
    "environment.PGID"                                = "1000"
    "environment.TZ"                                  = "Europe/Tallinn"
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
    "environment.RADARR__SERVER__ALLOWEDHOSTS"        = "radarr.cormo-tegu.ts.net,radarr.incus"
    "environment.RADARR__SERVER__BINDADDRESS"         = "*"
    "environment.RADARR__SERVER__ENABLESSL"           = "false"
    "environment.RADARR__SERVER__PORT"                = "7878"
    "environment.RADARR__SERVER__TRUSTEDNETWORKS"     = "${incus_instance.radarr_ts.ipv4_address},${incus_instance.radarr_ts.ipv6_address}"
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

resource "tailscale_oauth_client" "radarr" {
  description = "Radarr Tailscale gateway"
  scopes      = ["auth_keys"]
  tags        = ["tag:radarr"]

  depends_on = [tailscale_acl.policy]
}

resource "incus_storage_volume" "radarr_ts_state" {
  remote      = "hv01"
  project     = "default"
  name        = "radarr-ts-state"
  description = "Radarr Tailscale identity"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_volume" "radarr_ts_config" {
  remote      = "hv01"
  project     = "default"
  name        = "radarr-ts-config"
  description = "Radarr Tailscale Serve configuration"
  pool        = "local"

  file {
    content = jsonencode({
      TCP = {
        "443" = { HTTPS = true }
      }
      Web = {
        "$${TS_CERT_DOMAIN}:443" = {
          Handlers = {
            "/" = { Proxy = "http://radarr.incus:7878" }
          }
        }
      }
      AllowFunnel = {}
    })
    target_path = "/serve.json"
    mode        = "0644"
  }
}

resource "incus_instance" "radarr_ts" {
  remote      = "hv01"
  project     = "default"
  name        = "radarr-ts"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.5@sha256:c507f3a2a6ab1cabd8d809b98edeb41edbd5c3fb6ad9632ffd098b4c7d0b4065"
  description = "Radarr Tailscale HTTPS gateway"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_AUTHKEY"      = "${tailscale_oauth_client.radarr.key}?ephemeral=false"
    "environment.TS_AUTH_ONCE"    = "true"
    "environment.TS_HOSTNAME"     = "radarr"
    "environment.TS_EXTRA_ARGS"   = "--advertise-tags=tag:radarr"
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
      pool   = incus_storage_volume.radarr_ts_state.pool
      source = incus_storage_volume.radarr_ts_state.name
      path   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.radarr_ts_config.pool
      source   = incus_storage_volume.radarr_ts_config.name
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

variable "radarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

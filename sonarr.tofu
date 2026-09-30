# Sonarr

resource "incus_storage_volume" "sonarr_data" {
  remote      = "hv01"
  project     = "default"
  name        = "sonarr-data"
  description = "Sonarr configuration"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "sonarr" {
  remote      = "hv01"
  project     = "default"
  name        = "sonarr"
  image       = "oci-ghcr:linuxserver/sonarr:4.0.20.3014-ls326@sha256:f247545d23ba8b233d6604575347e48a623fe6ad75dda02348bf81917f3b5c06"
  description = "Sonarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"                                = "1000"
    "environment.PGID"                                = "1000"
    "environment.TZ"                                  = "Europe/Tallinn"
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
    "environment.SONARR__SERVER__ALLOWEDHOSTS"        = "sonarr.cormo-tegu.ts.net,sonarr.incus"
    "environment.SONARR__SERVER__BINDADDRESS"         = "*"
    "environment.SONARR__SERVER__ENABLESSL"           = "false"
    "environment.SONARR__SERVER__PORT"                = "8989"
    "environment.SONARR__SERVER__TRUSTEDNETWORKS"     = "${incus_instance.sonarr_ts.ipv4_address},${incus_instance.sonarr_ts.ipv6_address}"
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

resource "tailscale_oauth_client" "sonarr" {
  description = "Sonarr Tailscale gateway"
  scopes      = ["auth_keys"]
  tags        = ["tag:sonarr"]

  depends_on = [tailscale_acl.policy]
}

resource "incus_storage_volume" "sonarr_ts_state" {
  remote      = "hv01"
  project     = "default"
  name        = "sonarr-ts-state"
  description = "Sonarr Tailscale identity"
  pool        = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_volume" "sonarr_ts_config" {
  remote      = "hv01"
  project     = "default"
  name        = "sonarr-ts-config"
  description = "Sonarr Tailscale Serve configuration"
  pool        = "local"

  file {
    content = jsonencode({
      TCP = {
        "443" = { HTTPS = true }
      }
      Web = {
        "$${TS_CERT_DOMAIN}:443" = {
          Handlers = {
            "/" = { Proxy = "http://sonarr.incus:8989" }
          }
        }
      }
      AllowFunnel = {}
    })
    target_path = "/serve.json"
    mode        = "0644"
  }
}

resource "incus_instance" "sonarr_ts" {
  remote      = "hv01"
  project     = "default"
  name        = "sonarr-ts"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.5@sha256:c507f3a2a6ab1cabd8d809b98edeb41edbd5c3fb6ad9632ffd098b4c7d0b4065"
  description = "Sonarr Tailscale HTTPS gateway"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_AUTHKEY"      = "${tailscale_oauth_client.sonarr.key}?ephemeral=false"
    "environment.TS_AUTH_ONCE"    = "true"
    "environment.TS_HOSTNAME"     = "sonarr"
    "environment.TS_EXTRA_ARGS"   = "--advertise-tags=tag:sonarr"
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
      pool   = incus_storage_volume.sonarr_ts_state.pool
      source = incus_storage_volume.sonarr_ts_state.name
      path   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.sonarr_ts_config.pool
      source   = incus_storage_volume.sonarr_ts_config.name
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

variable "sonarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

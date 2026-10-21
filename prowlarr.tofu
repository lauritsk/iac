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
  image       = "oci-ghcr:linuxserver/prowlarr:2.6.5.5623-ls163@sha256:f9151e5bc1025c6d0a630d503210cdcb6bb55a7cc098562609d96a408d838902"
  description = "Prowlarr"
  profiles    = [incus_profile.default.name]
  running     = true

  config = {
    "environment.PUID"                   = "1000"
    "environment.PGID"                   = "1000"
    "environment.TZ"                     = "Europe/Tallinn"
    "environment.PROWLARR__AUTH__APIKEY" = var.prowlarr_api_key
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
  image       = "oci-dhi:tailscale:1.104.1@sha256:edd3f21753cf205327ca101a3cab449d8ec959f888ea2955737ce4a1e5173260"
  description = "Prowlarr Tailscale HTTPS gateway"
  profiles    = [incus_profile.default.name]
  running     = true

  config = {
    "environment.TS_AUTHKEY"             = "${tailscale_oauth_client.prowlarr.key}?ephemeral=false"
    "environment.TS_AUTH_ONCE"           = "true"
    "environment.TS_HOSTNAME"            = "prowlarr"
    "environment.TS_EXTRA_ARGS"          = "--advertise-tags=tag:prowlarr"
    "environment.TS_ACCEPT_DNS"          = "false"
    "environment.TS_USERSPACE"           = "false"
    "environment.TS_DEBUG_FIREWALL_MODE" = "nftables"
    "environment.TS_STATE_DIR"           = "/var/lib/tailscale"
    "environment.TS_SERVE_CONFIG"        = "/etc/tailscale/serve.json"
    "environment.TZ"                     = "Europe/Tallinn"
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

# Proxy

resource "incus_storage_volume" "proxy_config" {
  remote      = var.incus_remote
  project     = local.project
  name        = "proxy-config"
  description = "Proxy serve configuration"
  pool        = local.root_pool

  file {
    content     = jsonencode(jsondecode(file("${path.module}/serve.json")))
    target_path = "/serve.json"
    uid         = 0
    gid         = 0
    mode        = "0444"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "proxy_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "proxy-data"
  description = "Proxy state"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "proxy" {
  remote      = var.incus_remote
  project     = local.project
  name        = "proxy"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.4@sha256:2667499ed87ae29218f292556ba062918402dd5e92e93637af14867e4df12dd3"
  description = "Proxy for Incus applications"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_USERSPACE"                               = "false"
    "environment.TS_HOSTNAME"                                = "proxy"
    "environment.TS_AUTH_ONCE"                               = "true"
    "environment.TS_AUTHKEY"                                 = tailscale_oauth_client.proxy.key
    "environment.TS_STATE_DIR"                               = "/var/lib/tailscale"
    "environment.TS_SERVE_CONFIG"                            = "/config/serve.json"
    "environment.TS_EXTRA_ARGS"                              = "--advertise-tags=tag:container"
    "environment.TS_EXPERIMENTAL_SERVICE_AUTO_ADVERTISEMENT" = "true"
  }


  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.proxy_data.pool
      "source" = incus_storage_volume.proxy_data.name
      "path"   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.proxy_config.pool
      "source"   = incus_storage_volume.proxy_config.name
      "path"     = "/config"
      "readonly" = "true"
    }
  }
}

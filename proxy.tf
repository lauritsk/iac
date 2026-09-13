# Proxy

resource "incus_storage_volume" "proxy_config" {
  remote      = var.incus_remote
  project     = local.project
  name        = "proxy-config"
  description = "Proxy serve configuration and generated auth secret"
  pool        = incus_storage_pool.fast.name

  file {
    content     = jsonencode(jsondecode(file("${path.module}/serve.json")))
    target_path = "/serve.json"
    uid         = 0
    gid         = 0
    mode        = "0444"
  }

  file {
    content     = tailscale_oauth_client.proxy.key
    target_path = "/authkey"
    uid         = 0
    gid         = 0
    mode        = "0400"
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
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "proxy" {
  remote      = var.incus_remote
  project     = local.project
  name        = "proxy"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.3@sha256:8c42c4574ab066384fcb72f69e086a2ff1dd3652eb6f56856cee34bcf0d2f680"
  description = "Proxy for Incus applications"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_USERSPACE"                               = "false"
    "environment.TS_HOSTNAME"                                = "proxy"
    "environment.TS_AUTH_ONCE"                               = "true"
    "environment.TS_AUTHKEY"                                 = "file:/config/authkey"
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

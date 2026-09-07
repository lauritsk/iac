# Tailscale

resource "incus_storage_volume" "tailscale_config" {
  remote      = var.incus_remote
  project     = local.project
  name        = "tailscale-config"
  description = "Tailscale serve configuration and auth secret"
  pool        = incus_storage_pool.fast.name

  file {
    content     = jsonencode({ Services = local.tailscale_serve_services })
    target_path = "/serve.json"
    uid         = 0
    gid         = 0
    mode        = "0444"
  }

  file {
    content     = var.tailscale_oauth_secret
    target_path = "/tailscale_oauth_secret"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "tailscale_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "tailscale-data"
  description = "Tailscale state"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "tailscale" {
  remote      = var.incus_remote
  project     = local.project
  name        = "tailscale"
  image       = "oci-docker:tailscale/tailscale@sha256:8c42c4574ab066384fcb72f69e086a2ff1dd3652eb6f56856cee34bcf0d2f680"
  description = "Tailscale for Incus applications"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_USERSPACE"                               = "false"
    "environment.TS_HOSTNAME"                                = "tailscale"
    "environment.TS_AUTH_ONCE"                               = "true"
    "environment.TS_AUTHKEY"                                 = "file:/config/tailscale_oauth_secret"
    "environment.TS_STATE_DIR"                               = "/var/lib/tailscale"
    "environment.TS_SERVE_CONFIG"                            = "/config/serve.json"
    "environment.TS_EXTRA_ARGS"                              = "--advertise-tags=tag:container"
    "environment.TS_EXPERIMENTAL_SERVICE_AUTO_ADVERTISEMENT" = "true"
  }


  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.tailscale_data.name
      "path"   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.tailscale_config.name
      "path"     = "/config"
      "readonly" = "true"
    }
  }
}

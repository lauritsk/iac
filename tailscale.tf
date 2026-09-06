# Tailscale for Incus applications

resource "incus_storage_volume" "tailscale_config" {
  remote  = var.incus_remote
  project = "default"
  name    = "tailscale-config"
  pool    = "fast"

  file {
    source_path = "${path.module}/tailscale-serve.json"
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
}

import {
  to = incus_storage_volume.tailscale_config
  id = "${var.incus_remote}:default/fast/tailscale-config"
}

resource "incus_storage_volume" "tailscale_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "tailscale-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.tailscale_data
  id = "${var.incus_remote}:default/fast/tailscale-data"
}

resource "incus_instance" "tailscale" {
  remote      = var.incus_remote
  project     = "default"
  name        = "tailscale"
  image       = "oci-docker:tailscale/tailscale:latest"
  description = "Tailscale for Incus applications"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
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
      "pool"   = "fast"
      "source" = "tailscale-data"
      "path"   = "/var/lib/tailscale"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "tailscale-config"
      "path"     = "/config"
      "readonly" = "true"
    }
  }

  depends_on = [
    incus_storage_volume.tailscale_data,
    incus_storage_volume.tailscale_config,
  ]
}

import {
  to = incus_instance.tailscale
  id = "${var.incus_remote}:default/tailscale,image=oci-docker:tailscale/tailscale:latest"
}

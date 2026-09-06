# Tailscale OIDC identity provider

resource "incus_storage_volume" "tsidp_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "tsidp-data"
  pool    = "local"
  config = {
    "size"               = "1GiB"
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
  }
}

import {
  to = incus_storage_volume.tsidp_data
  id = "${var.incus_remote}:default/local/tsidp-data"
}

resource "incus_instance" "tsidp" {
  remote      = var.incus_remote
  project     = "default"
  name        = "tsidp"
  image       = "oci-ghcr:tailscale/tsidp:latest"
  description = "Tailscale OIDC identity provider"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TAILSCALE_USE_WIP_CODE" = "1"
    "environment.TS_STATE_DIR"           = "/data"
    "environment.TS_ADVERTISE_TAGS"      = "tag:tsidp"
    "environment.TS_AUTHKEY"             = var.tsidp_oauth_secret
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "local"
      "source" = "tsidp-data"
      "path"   = "/data"
    }
  }

  depends_on = [
    incus_storage_volume.tsidp_data,
  ]
}

import {
  to = incus_instance.tsidp
  id = "${var.incus_remote}:default/tsidp,image=oci-ghcr:tailscale/tsidp:latest"
}

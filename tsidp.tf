# Tailscale OIDC identity provider

resource "incus_storage_volume" "tsidp_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "tsidp-data"
  description = "Tailscale IdP state"
  pool        = "local"
  config = {
    "size"               = "1GiB"
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "tsidp" {
  remote      = var.incus_remote
  project     = local.project
  name        = "tsidp"
  image       = "oci-ghcr:tailscale/tsidp@sha256:9efe0bc423f08408d3a0427b493e09ff0bd270fb082ff51be5db26eb18a44067"
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
      "source" = incus_storage_volume.tsidp_data.name
      "path"   = "/data"
    }
  }
}

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
  image       = "oci-ghcr:tailscale/tsidp:v0.0.15@sha256:cae91835375efcbf75ecb8f9520e3472cda946e3ca9af1df3bce9540902f289e"
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

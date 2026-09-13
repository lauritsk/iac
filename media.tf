# Taildrive media server

resource "incus_storage_volume" "media_taildrive_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "media-taildrive-data"
  description = "Taildrive media server state"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "media_taildrive" {
  remote      = var.incus_remote
  project     = local.project
  name        = "media"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.3@sha256:8c42c4574ab066384fcb72f69e086a2ff1dd3652eb6f56856cee34bcf0d2f680"
  description = "Taildrive media server"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TS_USERSPACE"  = "false"
    "environment.TS_HOSTNAME"   = "media"
    "environment.TS_AUTH_ONCE"  = "true"
    "environment.TS_AUTHKEY"    = tailscale_oauth_client.media.key
    "environment.TS_STATE_DIR"  = "/var/lib/tailscale"
    "environment.TS_EXTRA_ARGS" = "--advertise-tags=tag:media"
  }


  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.media_taildrive_data.pool
      "source" = incus_storage_volume.media_taildrive_data.name
      "path"   = "/var/lib/tailscale"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.media.pool
      "source"   = incus_storage_volume.media.name
      "path"     = "/media"
      "readonly" = "true"
    }
  }
}


resource "terraform_data" "media_taildrive_share" {
  triggers_replace = {
    instance_name = incus_instance.media_taildrive.name
    state_volume  = incus_storage_volume.media_taildrive_data.name
    share_name    = "media"
    share_path    = "/media"
  }

  depends_on = [tailscale_acl.policy]

  provisioner "local-exec" {
    command = "incus exec ${var.incus_remote}:${incus_instance.media_taildrive.name} -- tailscale drive share media /media"
  }
}

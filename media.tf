# Taildrive media server

resource "incus_storage_volume" "media_taildrive_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "media-taildrive-data"
  description = "Taildrive media server state"
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "media_taildrive" {
  remote      = var.incus_remote
  project     = local.project
  name        = "media"
  image       = "oci-ghcr:tailscale/tailscale:v1.102.4@sha256:2667499ed87ae29218f292556ba062918402dd5e92e93637af14867e4df12dd3"
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
    name = "slow"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.media_slow.pool
      "source"   = incus_storage_volume.media_slow.name
      "path"     = "/data/slow"
      "readonly" = "true"
    }
  }

  device {
    name = "fast"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.media_fast.pool
      "source"   = incus_storage_volume.media_fast.name
      "path"     = "/data/fast"
      "readonly" = "true"
    }
  }
}


resource "terraform_data" "media_taildrive_slow_share" {
  triggers_replace = {
    instance_name = incus_instance.media_taildrive.name
    state_volume  = incus_storage_volume.media_taildrive_data.name
    share_name    = "slow"
    share_path    = "/data/slow"
  }

  depends_on = [tailscale_acl.policy]

  provisioner "local-exec" {
    command = "incus exec ${var.incus_remote}:${incus_instance.media_taildrive.name} -- tailscale drive share slow /data/slow"
  }
}

resource "terraform_data" "media_taildrive_fast_share" {
  triggers_replace = {
    instance_name = incus_instance.media_taildrive.name
    share_name    = "fast"
    share_path    = "/data/fast"
    volume_name   = incus_storage_volume.media_fast.name
  }

  depends_on = [tailscale_acl.policy]

  provisioner "local-exec" {
    command = "incus exec ${var.incus_remote}:${incus_instance.media_taildrive.name} -- tailscale drive share fast /data/fast"
  }
}

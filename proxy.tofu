resource "incus_instance" "proxy" {
  remote      = var.incus_remote
  project     = local.project
  name        = "proxy"
  image       = "images:debian/13/cloud"
  description = "Tailscale proxy and media server"
  profiles    = [incus_profile.default.name]
  running     = true

  config = {
    "boot.autostart"   = "true"
    "boot.autorestart" = "true"
    "cloud-init.user-data" = templatefile("${path.module}/proxy-cloud-init.yml.tftpl", {
      services           = local.service_backends
      tailscale_auth_key = tailscale_oauth_client.proxy.key
      timezone           = var.timezone
    })
  }

  device {
    name = "tpm"
    type = "tpm"

    properties = {
      "path"   = "/dev/tpm0"
      "pathrm" = "/dev/tpmrm0"
    }
  }

  device {
    name = "tun"
    type = "unix-char"

    properties = {
      "source" = "/dev/net/tun"
      "path"   = "/dev/net/tun"
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

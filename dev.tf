# Personal dev server

resource "incus_instance" "dev" {
  remote      = var.incus_remote
  project     = local.project
  name        = "dev"
  image       = "images:archlinux/current/cloud"
  description = "Personal dev server"
  type        = "container"
  profiles    = [incus_profile.default.name]
  running     = true

  config = {
    "cloud-init.user-data" = templatefile("${path.module}/dev.yaml.tftpl", {
      tailscale_authkey = trimspace(var.dev_tailscale_authkey)
    })
    "boot.autostart"             = "true"
    "limits.cpu"                 = "4"
    "limits.memory"              = "4GiB"
    "security.idmap.isolated"    = "true"
    "security.idmap.size"        = "262144"
    "security.protection.delete" = "true"
    "security.nesting"           = "true"
  }

  device {
    name = "tpm"
    type = "tpm"

    properties = {
      "path"   = "/dev/tpm0"
      "pathrm" = "/dev/tpmrm0"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

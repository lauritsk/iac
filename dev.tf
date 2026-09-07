# Personal dev server

resource "incus_instance" "dev" {
  remote      = var.incus_remote
  project     = "default"
  name        = "dev"
  image       = "images:archlinux/current/cloud"
  description = "Personal dev server"
  type        = "container"
  profiles    = ["default"]
  running     = true

  config = {
    "cloud-init.user-data" = templatefile("${path.module}/dev.yaml.tftpl", {
      tailscale_authkey = trimspace(var.dev_tailscale_authkey)
    })
    "boot.autostart"                       = "true"
    "limits.cpu"                           = "4"
    "limits.memory"                        = "4GiB"
    "security.idmap.isolated"              = "true"
    "security.protection.delete"           = "true"
    "security.nesting"                     = "true"
    "security.syscalls.intercept.mknod"    = "true"
    "security.syscalls.intercept.setxattr" = "true"
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

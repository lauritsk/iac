# Uptime Kuma

resource "incus_storage_volume" "uptime_kuma_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "uptime-kuma-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.uptime_kuma_data
  id = "${var.incus_remote}:default/fast/uptime-kuma-data"
}

resource "incus_instance" "uptime_kuma" {
  remote      = var.incus_remote
  project     = "default"
  name        = "uptime-kuma"
  image       = "oci-docker:louislam/uptime-kuma:latest"
  description = "Uptime Kuma"
  profiles    = [incus_profile.oci.name]
  running     = true

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "uptime-kuma-data"
      "path"   = "/app/data"
    }
  }

  depends_on = [
    incus_storage_volume.uptime_kuma_data,
  ]
}

import {
  to = incus_instance.uptime_kuma
  id = "${var.incus_remote}:default/uptime-kuma,image=oci-docker:louislam/uptime-kuma:latest"
}

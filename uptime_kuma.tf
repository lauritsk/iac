# Uptime Kuma

resource "incus_storage_volume" "uptime_kuma_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "uptime-kuma-data"
  description = "Uptime Kuma data"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "uptime_kuma" {
  remote      = var.incus_remote
  project     = local.project
  name        = "uptime-kuma"
  image       = "oci-docker:louislam/uptime-kuma@sha256:3e24e96c89efff0e3a4b0698cbdd36c15ad3022371db57166e5588853002ee5c"
  description = "Uptime Kuma"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ" = var.timezone
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.uptime_kuma_data.name
      "path"   = "/app/data"
    }
  }
}

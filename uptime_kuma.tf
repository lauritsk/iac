# Uptime Kuma

resource "incus_storage_volume" "uptime_kuma_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "uptime-kuma-data"
  pool    = "fast"
}


resource "incus_instance" "uptime_kuma" {
  remote      = var.incus_remote
  project     = "default"
  name        = "uptime-kuma"
  image       = "oci-docker:louislam/uptime-kuma:latest"
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
      "pool"   = "fast"
      "source" = incus_storage_volume.uptime_kuma_data.name
      "path"   = "/app/data"
    }
  }

}

# Recyclarr

resource "incus_storage_volume" "recyclarr_data" {
  remote      = "hv01"
  project     = "default"
  name        = "recyclarr-data"
  description = "Recyclarr configuration"
  pool        = "local"

  file {
    content = templatefile("${path.module}/recyclarr.yml.tftpl", {
      radarr_url = "http://radarr.incus:7878"
      sonarr_url = "http://sonarr.incus:8989"
    })
    target_path = "/recyclarr.yml"
    uid         = 1000
    gid         = 1000
    mode        = "0600"
  }
}


resource "incus_instance" "recyclarr" {
  remote      = "hv01"
  project     = "default"
  name        = "recyclarr"
  image       = "oci-ghcr:recyclarr/recyclarr:8.8.0@sha256:b1fbb929ba718fdbdac2c1fc25b32b0ae916d7a5a0892c2068c9bfae6f1a9209"
  description = "Recyclarr"
  profiles    = [incus_profile.default.name]
  running     = true

  config = {
    "environment.TINI_SUBREAPER" = "true"
    "environment.TZ"             = "Europe/Tallinn"
    "environment.CRON_SCHEDULE"  = "0 4 * * *"
    "environment.RADARR_API_KEY" = var.radarr_api_key
    "environment.SONARR_API_KEY" = var.sonarr_api_key
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.recyclarr_data.pool
      "source" = incus_storage_volume.recyclarr_data.name
      "path"   = "/config"
    }
  }

}

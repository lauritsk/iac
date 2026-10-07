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
  image       = "oci-ghcr:recyclarr/recyclarr:8.7.3@sha256:9c6c74d52cfc6f740a5a3624aa83867e171bb70b90453ddb7a4048b8c80445f9"
  description = "Recyclarr"
  profiles    = [incus_profile.oci.name]
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

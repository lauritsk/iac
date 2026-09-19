# Recyclarr

resource "incus_storage_volume" "recyclarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "recyclarr-data"
  description = "Recyclarr configuration"
  pool        = local.root_pool

  file {
    content = templatefile("${path.module}/recyclarr.yml.tftpl", {
      radarr_url = local.radarr_internal_url
      sonarr_url = local.sonarr_internal_url
    })
    target_path = "/recyclarr.yml"
    uid         = 1000
    gid         = 1000
    mode        = "0600"
  }
}


resource "incus_instance" "recyclarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "recyclarr"
  image       = "oci-ghcr:recyclarr/recyclarr:8.7.2@sha256:6e69e009e1cd7493ff6093e8e187b5d3788c75b4a2c0c5127b6a1beda1c19728"
  description = "Recyclarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TINI_SUBREAPER" = "true"
    "environment.TZ"             = var.timezone
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

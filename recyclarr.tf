# Recyclarr

resource "incus_storage_volume" "recyclarr_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "recyclarr-data"
  description = "Recyclarr configuration"
  pool        = incus_storage_pool.fast.name

  file {
    content     = file("${path.module}/recyclarr.yml")
    target_path = "/recyclarr.yml"
    uid         = 1000
    gid         = 1000
    mode        = "0600"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "recyclarr_secret" {
  remote      = var.incus_remote
  project     = local.project
  name        = "recyclarr-secret"
  description = "Arr API key secrets"
  pool        = incus_storage_pool.fast.name

  file {
    content     = var.prowlarr_api_key
    target_path = "/prowlarr_api_key"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }

  file {
    content     = var.radarr_api_key
    target_path = "/radarr_api_key"
    uid         = 1654
    gid         = 1654
    mode        = "0400"
  }

  file {
    content     = var.sonarr_api_key
    target_path = "/sonarr_api_key"
    uid         = 1654
    gid         = 1654
    mode        = "0400"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "recyclarr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "recyclarr"
  image       = "oci-ghcr:recyclarr/recyclarr@sha256:6e69e009e1cd7493ff6093e8e187b5d3788c75b4a2c0c5127b6a1beda1c19728"
  description = "Recyclarr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TINI_SUBREAPER" = "true"
    "environment.TZ"             = var.timezone
    "environment.CRON_SCHEDULE"  = "0 4 * * *"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.recyclarr_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.recyclarr_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }
}

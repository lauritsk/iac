# Transmission

resource "incus_storage_volume" "transmission_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-data"
  description = "Transmission configuration"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "transmission_secret" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-secret"
  description = "Transmission credentials"
  pool        = incus_storage_pool.fast.name

  file {
    content     = var.transmission_username
    target_path = "/transmission_username"
    uid         = 1000
    gid         = 1000
    mode        = "0400"
  }

  file {
    content     = var.transmission_password
    target_path = "/transmission_password"
    uid         = 1000
    gid         = 1000
    mode        = "0400"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "transmission_watch" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission-watch"
  description = "Transmission watch directory"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "transmission" {
  remote      = var.incus_remote
  project     = local.project
  name        = "transmission"
  image       = "oci-lscr:linuxserver/transmission@sha256:d38840f24a82c79fa837525fc4d89cf001a95b1fd4edcf41fba327c45d0f19f9"
  description = "Transmission"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.PUID"       = local.app_uid
    "environment.PGID"       = local.app_gid
    "environment.TZ"         = var.timezone
    "environment.FILE__USER" = "/run/secrets/transmission_username"
    "environment.FILE__PASS" = "/run/secrets/transmission_password"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.transmission_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "watch"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.fast.name
      "source" = incus_storage_volume.transmission_watch.name
      "path"   = "/watch"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = incus_storage_pool.slow.name
      "source" = incus_storage_volume.media.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_pool.fast.name
      "source"   = incus_storage_volume.transmission_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }
}

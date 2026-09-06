# Transmission

resource "incus_storage_volume" "transmission_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "transmission-data"
  pool    = "fast"
}


resource "incus_storage_volume" "transmission_secret" {
  remote  = var.incus_remote
  project = "default"
  name    = "transmission-secret"
  pool    = "fast"

  file {
    content     = var.transmission_username
    target_path = "/transmission_username"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }

  file {
    content     = var.transmission_password
    target_path = "/transmission_password"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }
}


resource "incus_storage_volume" "transmission_watch" {
  remote  = var.incus_remote
  project = "default"
  name    = "transmission-watch"
  pool    = "fast"
}


resource "incus_instance" "transmission" {
  remote      = var.incus_remote
  project     = "default"
  name        = "transmission"
  image       = "oci-lscr:linuxserver/transmission:latest"
  description = "Transmission"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.FILE__USER" = "/run/secrets/transmission_username"
    "environment.FILE__PASS" = "/run/secrets/transmission_password"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.transmission_data.name
      "path"   = "/config"
    }
  }

  device {
    name = "watch"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.transmission_watch.name
      "path"   = "/watch"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = "slow"
      "source" = incus_storage_volume.media.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.transmission_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

}

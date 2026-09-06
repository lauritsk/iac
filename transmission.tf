# Transmission

resource "incus_storage_volume" "transmission_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "transmission-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.transmission_data
  id = "${var.incus_remote}:default/fast/transmission-data"
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

import {
  to = incus_storage_volume.transmission_secret
  id = "${var.incus_remote}:default/fast/transmission-secret"
}

resource "incus_storage_volume" "transmission_watch" {
  remote  = var.incus_remote
  project = "default"
  name    = "transmission-watch"
  pool    = "fast"
}

import {
  to = incus_storage_volume.transmission_watch
  id = "${var.incus_remote}:default/fast/transmission-watch"
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
      "source" = "transmission-data"
      "path"   = "/config"
    }
  }

  device {
    name = "watch"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "transmission-watch"
      "path"   = "/watch"
    }
  }

  device {
    name = "media"
    type = "disk"

    properties = {
      "pool"   = "slow"
      "source" = "media"
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "transmission-secret"
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

  depends_on = [
    incus_storage_volume.transmission_data,
    incus_storage_volume.transmission_watch,
    incus_storage_volume.media,
    incus_storage_volume.transmission_secret,
  ]
}

import {
  to = incus_instance.transmission
  id = "${var.incus_remote}:default/transmission,image=oci-lscr:linuxserver/transmission:latest"
}

# Bichon email archive

resource "incus_storage_volume" "bichon_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "bichon-data"
  pool    = "fast"
}

import {
  to = incus_storage_volume.bichon_data
  id = "${var.incus_remote}:default/fast/bichon-data"
}

resource "incus_storage_volume" "bichon_secret" {
  remote  = var.incus_remote
  project = "default"
  name    = "bichon-secret"
  pool    = "fast"

  file {
    content     = var.bichon_encrypt_password
    target_path = "/bichon_encrypt_password"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }
}

import {
  to = incus_storage_volume.bichon_secret
  id = "${var.incus_remote}:default/fast/bichon-secret"
}

resource "incus_instance" "bichon" {
  remote      = var.incus_remote
  project     = "default"
  name        = "bichon"
  image       = "oci-ghcr:rustmailer/bichon:latest"
  description = "Bichon email archive"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.BICHON_PUBLIC_URL"            = "https://bichon.cormo-tegu.ts.net"
    "environment.BICHON_CORS_ORIGINS"          = "https://bichon.cormo-tegu.ts.net"
    "environment.BICHON_ENCRYPT_PASSWORD_FILE" = "/run/secrets/bichon_encrypt_password"
    "environment.BICHON_ROOT_DIR"              = "/data"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = "bichon-data"
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = "bichon-secret"
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

  depends_on = [
    incus_storage_volume.bichon_data,
    incus_storage_volume.bichon_secret,
  ]
}

import {
  to = incus_instance.bichon
  id = "${var.incus_remote}:default/bichon,image=oci-ghcr:rustmailer/bichon:latest"
}

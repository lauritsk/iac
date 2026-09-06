# Bichon email archive

resource "incus_storage_volume" "bichon_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "bichon-data"
  pool    = "fast"
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
      "source" = incus_storage_volume.bichon_data.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.bichon_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

}

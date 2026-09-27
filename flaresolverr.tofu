# FlareSolverr

resource "incus_instance" "flaresolverr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "flaresolverr"
  image       = "oci-ghcr:flaresolverr/flaresolverr:v3.5.2@sha256:c80ae007ce2ccdcd217a12426e4f039ef763ff90738c808d38810c3e59323767"
  description = "FlareSolverr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ" = var.timezone
  }
}

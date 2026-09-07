# FlareSolverr

resource "incus_instance" "flaresolverr" {
  remote      = var.incus_remote
  project     = "default"
  name        = "flaresolverr"
  image       = "oci-ghcr:flaresolverr/flaresolverr:latest"
  description = "FlareSolverr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ" = var.timezone
  }
}

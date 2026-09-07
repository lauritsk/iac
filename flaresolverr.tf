# FlareSolverr

resource "incus_instance" "flaresolverr" {
  remote      = var.incus_remote
  project     = local.project
  name        = "flaresolverr"
  image       = "oci-ghcr:flaresolverr/flaresolverr@sha256:139dfee1c6f89249c8d665d1333a42e8ec74ec0a86bc6bb1c8461e10d3a66a47"
  description = "FlareSolverr"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ" = var.timezone
  }
}

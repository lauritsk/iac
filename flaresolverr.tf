# FlareSolverr

resource "incus_instance" "flaresolverr" {
  remote      = var.incus_remote
  project     = "default"
  name        = "flaresolverr"
  image       = "oci-docker:flaresolverr/flaresolverr:latest"
  description = "FlareSolverr"
  profiles    = [incus_profile.oci.name]
  running     = true
}

import {
  to = incus_instance.flaresolverr
  id = "${var.incus_remote}:default/flaresolverr,image=oci-docker:flaresolverr/flaresolverr:latest"
}

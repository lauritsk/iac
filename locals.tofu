# Shared local values

locals {
  root_pool      = "local"
  project        = "default"
  app_uid        = "1000"
  app_gid        = "1000"
  tailnet_domain = "cormo-tegu.ts.net"

  snapshot_config = {
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
  }

  service_backends = {
    jellyfin     = "http://jellyfin.incus:8096"
    prowlarr     = "http://prowlarr.incus:9696"
    radarr       = "http://radarr.incus:7878"
    sonarr       = "http://sonarr.incus:8989"
    transmission = "http://transmission.incus:9091"
  }
}

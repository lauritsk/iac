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

  radarr_internal_url         = "http://${incus_instance.radarr.name}:7878"
  sonarr_internal_url         = "http://${incus_instance.sonarr.name}:8989"
  immich_machine_learning_url = "http://${incus_instance.immich_machine_learning.name}:3003"
  jellyfin_internal_url       = "http://${incus_instance.jellyfin.name}:8096"
}

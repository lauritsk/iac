# Shared local values

locals {
  project        = "default"
  app_uid        = "1000"
  app_gid        = "1000"
  tailnet_domain = "cormo-tegu.ts.net"

  tailscale_serve_services = {
    "svc:beszel" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "beszel.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://beszel:8090" } } } }
    }
    "svc:uptime-kuma" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "uptime-kuma.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://uptime-kuma:3001" } } } }
    }
    "svc:zerobyte" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "zerobyte.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://zerobyte:4096" } } } }
    }
    "svc:jellyfin" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "jellyfin.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://jellyfin:8096" } } } }
    }
    "svc:prowlarr" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "prowlarr.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://prowlarr:9696" } } } }
    }
    "svc:radarr" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "radarr.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://radarr:7878" } } } }
    }
    "svc:sonarr" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "sonarr.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://sonarr:8989" } } } }
    }
    "svc:transmission" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "transmission.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://transmission:9091" } } } }
    }
    "svc:immich" = {
      TCP = { "443" = { HTTPS = true } }
      Web = { "immich.${local.tailnet_domain}:443" = { Handlers = { "/" = { Proxy = "http://immich-server:2283" } } } }
    }
  }
}

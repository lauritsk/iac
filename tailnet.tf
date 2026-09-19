# Tailscale tailnet control plane

provider "tailscale" {}


resource "tailscale_oauth_client" "media" {
  description = "Taildrive media server"
  scopes      = ["auth_keys"]
  tags        = ["tag:media"]

  depends_on = [tailscale_acl.policy]
}

resource "tailscale_oauth_client" "proxy" {
  description = "Proxy"
  scopes      = ["auth_keys"]
  tags        = ["tag:container"]

  depends_on = [tailscale_acl.policy]
}

resource "tailscale_oauth_client" "tsidp" {
  description = "Tailscale identity provider"
  scopes      = ["auth_keys"]
  tags        = ["tag:tsidp"]

  depends_on = [tailscale_acl.policy]
}

resource "tailscale_service" "immich" {
  name    = "svc:immich"
  comment = "Immich"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_service" "jellyfin" {
  name    = "svc:jellyfin"
  comment = "Jellyfin"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_service" "prowlarr" {
  name    = "svc:prowlarr"
  comment = "Prowlarr"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_service" "radarr" {
  name    = "svc:radarr"
  comment = "Radarr"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_service" "sonarr" {
  name    = "svc:sonarr"
  comment = "Sonarr"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_service" "transmission" {
  name    = "svc:transmission"
  comment = "Transmission"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_service" "zerobyte" {
  name    = "svc:zerobyte"
  comment = "Zerobyte"
  ports   = ["tcp:443"]
  tags    = ["tag:app"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "tailscale_acl" "policy" {
  acl                        = file("${path.module}/policy.hujson")
  overwrite_existing_content = false
  reset_acl_on_destroy       = false

  lifecycle {
    prevent_destroy = true
  }
}

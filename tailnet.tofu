# Tailscale tailnet control plane

provider "tailscale" {}


resource "tailscale_oauth_client" "proxy" {
  description = "Tailscale proxy and media server"
  scopes      = ["auth_keys"]
  tags        = ["tag:server"]

  depends_on = [tailscale_acl.policy]
}

resource "tailscale_oauth_client" "tsidp" {
  description = "Tailscale identity provider"
  scopes      = ["auth_keys"]
  tags        = ["tag:tsidp"]

  depends_on = [tailscale_acl.policy]
}

resource "tailscale_service" "app" {
  for_each = local.service_backends

  name    = "svc:${each.key}"
  comment = title(each.key)
  ports   = ["tcp:443"]
  tags    = ["tag:app"]
}

resource "tailscale_acl" "policy" {
  acl                        = file("${path.module}/policy.hujson")
  overwrite_existing_content = false
  reset_acl_on_destroy       = false

  lifecycle {
    prevent_destroy = true
  }
}

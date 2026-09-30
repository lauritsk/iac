# Tailscale tailnet control plane

provider "tailscale" {}

resource "tailscale_federated_identity" "ci" {
  description = "GitHub Actions for lauritsk iac"
  scopes      = ["auth_keys"]
  tags        = ["tag:ci"]
  issuer      = "https://token.actions.githubusercontent.com"
  subject     = "repo:lauritsk@224454725/iac@1328782743:ref:refs/heads/main"

  custom_claim_rules = {
    repository   = "lauritsk/iac"
    workflow_ref = "lauritsk/iac/.github/workflows/ci.yml@refs/heads/main"
    event_name   = "workflow_dispatch"
  }

  depends_on = [tailscale_acl.policy]
}

output "tailscale_ci_client_id" {
  value = tailscale_federated_identity.ci.id
}

output "tailscale_ci_audience" {
  value = tailscale_federated_identity.ci.audience
}


resource "tailscale_oauth_client" "proxy" {
  description = "Tailscale proxy and media server"
  scopes      = ["auth_keys"]
  tags        = ["tag:server"]

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

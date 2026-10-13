provider "cloudflare" {}

variable "cloudflare_account_id" {
  type     = string
  nullable = false

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.cloudflare_account_id))
    error_message = "Use the 32-character Cloudflare account ID."
  }
}

variable "cloudflare_zone_id" {
  type     = string
  nullable = false

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.cloudflare_zone_id))
    error_message = "Use the 32-character zone ID for laurits.dev."
  }
}

variable "blog_origin_url" {
  type        = string
  nullable    = false
  description = "Caddy HTTP URL reachable from the cloudflared instance."

  validation {
    condition     = can(regex("^http://[^/]+:8080$", var.blog_origin_url))
    error_message = "Use Caddy's internal HTTP address on port 8080, without a trailing slash."
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "blog" {
  account_id = var.cloudflare_account_id
  name       = "blog"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "blog" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.blog.id

  config = {
    ingress = [
      {
        hostname = "blog.laurits.dev"
        service  = var.blog_origin_url
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "blog" {
  zone_id = var.cloudflare_zone_id
  name    = "blog.laurits.dev"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.blog.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

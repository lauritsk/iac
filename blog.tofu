resource "incus_storage_volume" "blog_data" {
  remote      = "hv01"
  project     = "default"
  name        = "blog-data"
  description = "Blog site and Caddy configuration"
  pool        = "local"

  file {
    content     = file("${path.module}/blog/Caddyfile")
    target_path = "/Caddyfile"
    mode        = "0644"
  }

  dynamic "file" {
    for_each = fileset("${path.module}/blog/public", "**")

    content {
      content            = file("${path.module}/blog/public/${file.value}")
      target_path        = "/site/${file.value}"
      create_directories = true
      directory_mode     = "0755"
      mode               = "0644"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_instance" "blog" {
  remote      = "hv01"
  project     = "default"
  name        = "blog"
  image       = "oci-redhat:hi/caddy:2.11.7@sha256:e7349895c9855475e72cc5a1067c4aee98c7b4e6633fa4c75f9326c4b2f36691"
  description = "Blog (Caddy)"
  profiles    = [incus_profile.default.name]
  running     = true

  device {
    name = "data"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.blog_data.pool
      source   = "${incus_storage_volume.blog_data.name}/site"
      path     = "/srv"
      readonly = "true"
    }
  }

  device {
    name = "config"
    type = "disk"

    properties = {
      pool     = incus_storage_volume.blog_data.pool
      source   = incus_storage_volume.blog_data.name
      path     = "/etc/caddy"
      readonly = "true"
    }
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "blog" {
  account_id = "3f16907023eaba3dd46b1ed3cf77c83f"
  name       = "blog"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "blog" {
  account_id = cloudflare_zero_trust_tunnel_cloudflared.blog.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.blog.id

  config = {
    ingress = [
      {
        hostname = "blog.laurits.dev"
        service  = "http://${incus_instance.blog.name}.incus:8080"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "blog" {
  account_id = cloudflare_zero_trust_tunnel_cloudflared.blog.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.blog.id
}

resource "incus_instance" "blog_cf" {
  remote      = "hv01"
  project     = "default"
  name        = "blog-cf"
  image       = "oci-dhi:cloudflared:2026@sha256:9074da1ca4d9d0285233215dcf0ebae8de06f6775a6701f404f38e8c6bc393f9"
  description = "Blog (Cloudflare Tunnel)"
  profiles    = [incus_profile.default.name]
  running     = true

  config = sensitive({
    "oci.entrypoint"           = "cloudflared --no-autoupdate tunnel run"
    "environment.TUNNEL_TOKEN" = data.cloudflare_zero_trust_tunnel_cloudflared_token.blog.token
  })

  depends_on = [cloudflare_zero_trust_tunnel_cloudflared_config.blog]
}

resource "cloudflare_dns_record" "blog" {
  zone_id = "11c4f12c9f293753f69ffa298abc5683"
  name    = "blog.laurits.dev"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.blog.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

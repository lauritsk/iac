# OpenTofu configuration

terraform {
  required_version = "= 1.13.1"

  encryption {
    key_provider "pbkdf2" "local" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "local" {
      keys = key_provider.pbkdf2.local
    }

    state {
      method   = method.aes_gcm.local
      enforced = true
    }

    plan {
      method   = method.aes_gcm.local
      enforced = true
    }
  }

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29.2"
    }
    incus = {
      source  = "lxc/incus"
      version = "~> 1.2"
    }
  }
}

provider "incus" {
  config_dir     = pathexpand("~/Library/Application Support/incus")
  default_remote = "hv01"

  remote {
    name                = "hv01"
    address             = "https://hv01.cormo-tegu.ts.net:8443"
    protocol            = "incus"
    authentication_type = "tls"
  }

  remote {
    name     = "images"
    address  = "https://images.linuxcontainers.org"
    protocol = "simplestreams"
    public   = true
  }

  remote {
    name               = "oci-ghcr"
    address            = "https://ghcr.io"
    protocol           = "oci"
    public             = true
    credentials_helper = "docker-credential-osxkeychain"
  }

}

# Input variables

variable "state_passphrase" {
  type      = string
  sensitive = true
  nullable  = false
}

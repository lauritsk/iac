# OpenTofu configuration

terraform {
  required_version = "= 1.12.6"

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
    name               = "oci-docker"
    address            = "https://docker.io"
    protocol           = "oci"
    public             = true
    credentials_helper = "docker-credential-osxkeychain"
  }

  remote {
    name               = "oci-ghcr"
    address            = "https://ghcr.io"
    protocol           = "oci"
    public             = true
    credentials_helper = "docker-credential-osxkeychain"
  }

  remote {
    name               = "oci-dhi"
    address            = "https://dhi.io"
    protocol           = "oci"
    public             = true
    credentials_helper = "docker-credential-osxkeychain"
  }
}

# Shared local values

locals {
  root_pool      = "local"
  project        = "default"
  app_uid        = "1000"
  app_gid        = "1000"
  tailnet_domain = "cormo-tegu.ts.net"

  service_backends = {
    radarr = "http://radarr.incus:7878"
    sonarr = "http://sonarr.incus:8989"
  }
}

# Input variables

variable "prowlarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "radarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "sonarr_api_key" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "state_passphrase" {
  type      = string
  sensitive = true
  nullable  = false
}

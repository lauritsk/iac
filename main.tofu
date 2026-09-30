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
  default_remote = var.incus_remote

  remote {
    name                = var.incus_remote
    address             = var.incus_address
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

# Input variables

variable "incus_remote" {
  description = "Incus client remote that points at the homelab server"
  type        = string
  default     = "hv01"
}

variable "incus_address" {
  description = "HTTPS API endpoint of the homelab Incus server"
  type        = string
  default     = "https://hv01.cormo-tegu.ts.net:8443"
  nullable    = false
}

variable "timezone" {
  description = "IANA time zone passed to containers that support TZ."
  type        = string
  default     = "Europe/Tallinn"
}

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

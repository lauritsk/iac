# OpenTofu configuration

terraform {
  required_version = ">= 1.10.0"

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

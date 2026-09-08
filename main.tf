# OpenTofu configuration

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket = "terraform-state"
    key    = "lauritsk-iac/terraform.tfstate"
    region = "us-east-1"

    endpoints = {
      s3 = "https://hv01.cormo-tegu.ts.net:8555"
    }

    use_path_style              = true
    insecure                    = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
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
  config_dir     = pathexpand("~/.config/incus")
  default_remote = var.incus_remote

  remote {
    name                = var.incus_remote
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
    name     = "oci-docker"
    address  = "https://docker.io"
    protocol = "oci"
    public   = true
  }

  remote {
    name     = "oci-ghcr"
    address  = "https://ghcr.io"
    protocol = "oci"
    public   = true
  }

  remote {
    name     = "oci-lscr"
    address  = "https://lscr.io"
    protocol = "oci"
    public   = true
  }
}


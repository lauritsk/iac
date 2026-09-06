terraform {
  required_version = ">= 1.10.0"

  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "~> 1.2"
    }
  }
}

provider "incus" {
  config_dir     = pathexpand(var.incus_config_dir)
  default_remote = var.incus_remote

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

# Shared OCI profile and storage

resource "incus_profile" "oci" {
  remote      = var.incus_remote
  project     = "default"
  name        = "oci"
  description = "OCI application defaults"

  config = {
    "boot.autostart"             = "true"
    "boot.autorestart"           = "true"
    "security.protection.delete" = "true"
  }

  device {
    name = "root"
    type = "disk"

    properties = {
      pool = "local"
      path = "/"
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network = "incusbr0"
    }
  }
}

import {
  to = incus_profile.oci
  id = "${var.incus_remote}:default/oci"
}

resource "incus_storage_volume" "media" {
  remote  = var.incus_remote
  project = "default"
  name    = "media"
  pool    = "slow"
}

import {
  to = incus_storage_volume.media
  id = "${var.incus_remote}:default/slow/media"
}

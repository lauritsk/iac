# Incus platform

resource "incus_storage_pool" "fast" {
  remote      = var.incus_remote
  name        = "fast"
  driver      = "zfs"
  description = "App storage (external SSD)"
}

resource "incus_storage_pool" "slow" {
  remote      = var.incus_remote
  name        = "slow"
  driver      = "zfs"
  description = "Media storage (external HDD)"
}

resource "incus_network" "incusbr0" {
  remote      = var.incus_remote
  project     = local.project
  name        = "incusbr0"
  type        = "bridge"
  description = "Local network bridge (NAT)"

  config = {
    "ipv4.address" = "10.254.93.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "fd42:fd4:f478:bae8::1/64"
    "ipv6.nat"     = "true"
  }
}

resource "incus_profile" "default" {
  remote      = var.incus_remote
  project     = local.project
  name        = "default"
  description = "Default Incus profile"

  config = local.snapshot_config

  device {
    name = "root"
    type = "disk"

    properties = {
      pool = local.root_pool
      path = "/"
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network = incus_network.incusbr0.name
    }
  }
}

# Shared OCI profile and storage

resource "incus_profile" "oci" {
  remote      = var.incus_remote
  project     = local.project
  name        = "oci"
  description = "OCI application defaults"

  config = {
    "boot.autostart"   = "true"
    "boot.autorestart" = "true"
  }

  device {
    name = "root"
    type = "disk"

    properties = {
      pool = local.root_pool
      path = "/"
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network = incus_network.incusbr0.name
    }
  }
}

resource "incus_storage_volume" "media" {
  remote      = var.incus_remote
  project     = local.project
  name        = "media"
  description = "Shared media library and downloads"
  pool        = incus_storage_pool.slow.name

  lifecycle {
    prevent_destroy = true
  }
}

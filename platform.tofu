# Incus platform

resource "incus_storage_pool" "fast" {
  remote      = "hv01"
  name        = "fast"
  driver      = "zfs"
  description = "Media library (external SSD)"
}

resource "incus_storage_pool" "slow" {
  remote      = "hv01"
  name        = "slow"
  driver      = "zfs"
  description = "Media library (external HDD)"
}

resource "incus_network" "incusbr0" {
  remote      = "hv01"
  project     = "default"
  name        = "incusbr0"
  type        = "bridge"
  description = "Local network bridge (NAT)"

  config = {
    "ipv4.address" = "10.100.0.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "fd42:fd4:f478:bae8::1/64"
    "ipv6.nat"     = "true"
  }
}

resource "incus_profile" "default" {
  remote      = "hv01"
  project     = "default"
  name        = "default"
  description = "Default Incus profile"

  config = {
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
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
      network = incus_network.incusbr0.name
    }
  }
}

# Shared OCI profile and storage

resource "incus_profile" "oci" {
  remote      = "hv01"
  project     = "default"
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
      pool = "local"
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

resource "incus_storage_volume" "media_slow" {
  remote      = "hv01"
  project     = "default"
  name        = "media"
  description = "Shared media library and downloads"
  pool        = incus_storage_pool.slow.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "incus_storage_volume" "media_fast" {
  remote      = "hv01"
  project     = "default"
  name        = "media"
  description = "Fast shared media library and downloads"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}

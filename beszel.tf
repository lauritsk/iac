# Beszel hub

resource "incus_storage_volume" "beszel_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "beszel-data"
  pool    = "fast"
}


resource "incus_instance" "beszel" {
  remote      = var.incus_remote
  project     = "default"
  name        = "beszel"
  image       = "oci-docker:henrygd/beszel:latest"
  description = "Beszel hub"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.APP_URL"       = "https://beszel.cormo-tegu.ts.net"
    "environment.USER_EMAIL"    = var.beszel_user_email
    "environment.USER_PASSWORD" = var.beszel_user_password
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.beszel_data.name
      "path"   = "/beszel_data"
    }
  }

}


# Beszel agent for hv01

resource "incus_storage_volume" "beszel_agent_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "beszel-agent-data"
  pool    = "local"
  config = {
    "security.shifted"   = "true"
    "size"               = "1GiB"
    "snapshots.schedule" = "@daily"
    "snapshots.expiry"   = "7d"
    "snapshots.pattern"  = "auto-%Y%m%d-%H%M"
  }

  file {
    content     = var.beszel_agent_key
    target_path = "/key"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }

  file {
    content     = var.beszel_agent_token
    target_path = "/token"
    uid         = 0
    gid         = 0
    mode        = "0400"
  }
}


resource "incus_instance" "beszel_agent" {
  remote      = var.incus_remote
  project     = "default"
  name        = "beszel-agent"
  image       = "oci-docker:henrygd/beszel-agent-intel:latest"
  description = "Beszel agent for hv01"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "security.privileged"       = "true"
    "raw.lxc"                   = "lxc.cap.drop="
    "environment.DISABLE_SSH"   = "true"
    "environment.HUB_URL"       = "https://beszel.cormo-tegu.ts.net"
    "environment.SYSTEM_NAME"   = "hv01"
    "environment.KEY_FILE"      = "/var/lib/beszel-agent/key"
    "environment.TOKEN_FILE"    = "/var/lib/beszel-agent/token"
    "environment.SMART_DEVICES" = "/dev/nvme0,/dev/sda:sntasmedia,/dev/sdb:sat"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "local"
      "source" = incus_storage_volume.beszel_agent_data.name
      "path"   = "/var/lib/beszel-agent"
    }
  }

  device {
    name = "systemd-dbus"
    type = "disk"

    properties = {
      "source"   = "/run/dbus/system_bus_socket"
      "path"     = "/run/dbus/system_bus_socket"
      "readonly" = "true"
    }
  }

  device {
    name = "disk-local"
    type = "disk"

    properties = {
      "source"   = "/var/lib/incus/storage-pools/local"
      "path"     = "/extra-filesystems/local"
      "readonly" = "true"
    }
  }

  device {
    name = "zfs"
    type = "unix-char"

    properties = {
      "source" = "/dev/zfs"
      "path"   = "/dev/zfs"
    }
  }

  device {
    name = "nvme0"
    type = "unix-char"

    properties = {
      "source" = "/dev/nvme0"
      "path"   = "/dev/nvme0"
    }
  }

  device {
    name = "sda"
    type = "unix-block"

    properties = {
      "source" = "/dev/sda"
      "path"   = "/dev/sda"
    }
  }

  device {
    name = "sdb"
    type = "unix-block"

    properties = {
      "source" = "/dev/sdb"
      "path"   = "/dev/sdb"
    }
  }

  device {
    name = "gpu"
    type = "gpu"

    properties = {
    }
  }

}

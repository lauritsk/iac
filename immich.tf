# Immich PostgreSQL

resource "incus_storage_volume" "immich_db_secret" {
  remote  = var.incus_remote
  project = "default"
  name    = "immich-db-secret"
  pool    = "fast"

  file {
    content     = var.immich_db_name
    target_path = "/immich_db_name"
    uid         = 1000
    gid         = 1000
    mode        = "0400"
  }

  file {
    content     = var.immich_db_username
    target_path = "/immich_db_username"
    uid         = 1000
    gid         = 1000
    mode        = "0400"
  }

  file {
    content     = var.immich_db_password
    target_path = "/immich_db_password"
    uid         = 1000
    gid         = 1000
    mode        = "0400"
  }
}


resource "incus_storage_volume" "immich_postgres_data" {
  remote  = var.incus_remote
  project = "default"
  name    = "immich-postgres-data"
  pool    = "fast"

  file {
    content     = ""
    target_path = "/postgresql.override.conf"
    uid         = 999
    gid         = 999
    mode        = "0644"
  }
}


resource "incus_instance" "immich_postgres" {
  remote      = var.incus_remote
  project     = "default"
  name        = "immich-postgres"
  image       = "oci-ghcr:immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0"
  description = "Immich PostgreSQL"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ"                     = var.timezone
    "environment.POSTGRES_DB_FILE"       = "/run/secrets/immich_db_name"
    "environment.POSTGRES_USER_FILE"     = "/run/secrets/immich_db_username"
    "environment.POSTGRES_PASSWORD_FILE" = "/run/secrets/immich_db_password"
  }

  device {
    name = "data"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.immich_postgres_data.name
      "path"   = "/var/lib/postgresql/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.immich_db_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

}


# Immich Valkey

resource "incus_instance" "immich_valkey" {
  remote      = var.incus_remote
  project     = "default"
  name        = "immich-valkey"
  image       = "oci-docker:valkey/valkey:9"
  description = "Immich Valkey"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ"             = var.timezone
    "environment.TINI_SUBREAPER" = "true"
  }
}


# Immich machine learning

resource "incus_storage_volume" "immich_machine_learning_cache" {
  remote  = var.incus_remote
  project = "default"
  name    = "immich-machine-learning-cache"
  pool    = "fast"

  file {
    content            = ""
    target_path        = "/matplotlib/.keep"
    create_directories = true
    directory_mode     = "0700"
    uid                = 1000
    gid                = 1000
    mode               = "0600"
  }
}


resource "incus_instance" "immich_machine_learning" {
  remote      = var.incus_remote
  project     = "default"
  name        = "immich-machine-learning"
  image       = "oci-ghcr:immich-app/immich-machine-learning:release-openvino"
  description = "Immich machine learning"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "oci.uid"                    = "1000"
    "oci.gid"                    = "1000"
    "environment.TZ"             = var.timezone
    "environment.TINI_SUBREAPER" = "true"
    "environment.MPLCONFIGDIR"   = "/cache/matplotlib"
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.immich_machine_learning_cache.name
      "path"   = "/cache"
    }
  }

  device {
    name = "gpu"
    type = "gpu"

    properties = {
      "mode" = "0666"
    }
  }

}


# Immich server

resource "incus_storage_volume" "immich_library" {
  remote  = var.incus_remote
  project = "default"
  name    = "immich-library"
  pool    = "fast"
}


resource "incus_instance" "immich_server" {
  remote      = var.incus_remote
  project     = "default"
  name        = "immich-server"
  image       = "oci-ghcr:immich-app/immich-server:release"
  description = "Immich server"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "oci.uid"                                 = "1000"
    "oci.gid"                                 = "1000"
    "environment.TINI_SUBREAPER"              = "true"
    "environment.TZ"                          = var.timezone
    "environment.IMMICH_HOST"                 = "0.0.0.0"
    "environment.DB_HOSTNAME"                 = "immich-postgres"
    "environment.DB_USERNAME_FILE"            = "/run/secrets/immich_db_username"
    "environment.DB_PASSWORD_FILE"            = "/run/secrets/immich_db_password"
    "environment.DB_DATABASE_NAME_FILE"       = "/run/secrets/immich_db_name"
    "environment.REDIS_HOSTNAME"              = "immich-valkey"
    "environment.MACHINE_LEARNING_URL"        = "http://immich-machine-learning:3003"
    "environment.IMMICH_MACHINE_LEARNING_URL" = "http://immich-machine-learning:3003"
  }

  device {
    name = "library"
    type = "disk"

    properties = {
      "pool"   = "fast"
      "source" = incus_storage_volume.immich_library.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = "fast"
      "source"   = incus_storage_volume.immich_db_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }

  device {
    name = "gpu"
    type = "gpu"

    properties = {
      "mode" = "0666"
    }
  }

}

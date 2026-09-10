# Immich

# PostgreSQL

resource "incus_storage_volume" "immich_db_secret" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-db-secret"
  description = "Immich database secrets"
  pool        = incus_storage_pool.fast.name

  file {
    content     = var.immich_db_name
    target_path = "/immich_db_name"
    uid         = local.app_uid
    gid         = local.app_gid
    mode        = "0400"
  }

  file {
    content     = var.immich_db_username
    target_path = "/immich_db_username"
    uid         = local.app_uid
    gid         = local.app_gid
    mode        = "0400"
  }

  file {
    content     = var.immich_db_password
    target_path = "/immich_db_password"
    uid         = local.app_uid
    gid         = local.app_gid
    mode        = "0400"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_storage_volume" "immich_postgres_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-postgres-data"
  description = "Immich PostgreSQL data"
  pool        = incus_storage_pool.fast.name

  file {
    content     = ""
    target_path = "/postgresql.override.conf"
    uid         = 999
    gid         = 999
    mode        = "0644"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "immich_postgres" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-postgres"
  image       = "oci-ghcr:immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23"
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
      "pool"   = incus_storage_volume.immich_postgres_data.pool
      "source" = incus_storage_volume.immich_postgres_data.name
      "path"   = "/var/lib/postgresql/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.immich_db_secret.pool
      "source"   = incus_storage_volume.immich_db_secret.name
      "path"     = "/run/secrets"
      "readonly" = "true"
    }
  }
}


# Valkey

resource "incus_instance" "immich_valkey" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-valkey"
  image       = "oci-docker:valkey/valkey:9@sha256:c123e3715db63d06d4ad6964884037aa0d5d4d703939b9929954112889708e1d"
  description = "Immich Valkey"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "environment.TZ"             = var.timezone
    "environment.TINI_SUBREAPER" = "true"
  }
}


# Machine learning

resource "incus_storage_volume" "immich_machine_learning_cache" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-machine-learning-cache"
  description = "Immich machine learning cache"
  pool        = incus_storage_pool.fast.name

  file {
    content            = ""
    target_path        = "/matplotlib/.keep"
    create_directories = true
    directory_mode     = "0700"
    uid                = local.app_uid
    gid                = local.app_gid
    mode               = "0600"
  }

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "immich_machine_learning" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-machine-learning"
  image       = "oci-ghcr:immich-app/immich-machine-learning:v3.1.0-openvino@sha256:4b6ef958e7749fc548377bb23ee219c09c74da8decee080d76dc6a388c39b013"
  description = "Immich machine learning"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "oci.uid"                    = local.app_uid
    "oci.gid"                    = local.app_gid
    "environment.TZ"             = var.timezone
    "environment.TINI_SUBREAPER" = "true"
    "environment.MPLCONFIGDIR"   = "/cache/matplotlib"
  }

  device {
    name = "cache"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.immich_machine_learning_cache.pool
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


# Server

resource "incus_storage_volume" "immich_library" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-library"
  description = "Immich photo library"
  pool        = incus_storage_pool.fast.name

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "immich_server" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-server"
  image       = "oci-ghcr:immich-app/immich-server:v3.1.0@sha256:b434cb9287eea1471c9974845914d4dd328c9c2d652e446ed4930f99944f0ceb"
  description = "Immich server"
  profiles    = [incus_profile.oci.name]
  running     = true

  config = {
    "oci.uid"                                 = local.app_uid
    "oci.gid"                                 = local.app_gid
    "environment.TINI_SUBREAPER"              = "true"
    "environment.TZ"                          = var.timezone
    "environment.IMMICH_HOST"                 = "0.0.0.0"
    "environment.DB_HOSTNAME"                 = incus_instance.immich_postgres.name
    "environment.DB_USERNAME_FILE"            = "/run/secrets/immich_db_username"
    "environment.DB_PASSWORD_FILE"            = "/run/secrets/immich_db_password"
    "environment.DB_DATABASE_NAME_FILE"       = "/run/secrets/immich_db_name"
    "environment.REDIS_HOSTNAME"              = incus_instance.immich_valkey.name
    "environment.MACHINE_LEARNING_URL"        = local.immich_machine_learning_url
    "environment.IMMICH_MACHINE_LEARNING_URL" = local.immich_machine_learning_url
  }

  device {
    name = "library"
    type = "disk"

    properties = {
      "pool"   = incus_storage_volume.immich_library.pool
      "source" = incus_storage_volume.immich_library.name
      "path"   = "/data"
    }
  }

  device {
    name = "secret"
    type = "disk"

    properties = {
      "pool"     = incus_storage_volume.immich_db_secret.pool
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

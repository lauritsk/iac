# Immich

# PostgreSQL

resource "incus_storage_volume" "immich_postgres_data" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-postgres-data"
  description = "Immich PostgreSQL data"
  pool        = local.root_pool

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
    "environment.TZ"                = var.timezone
    "environment.POSTGRES_DB"       = var.immich_db_name
    "environment.POSTGRES_USER"     = var.immich_db_username
    "environment.POSTGRES_PASSWORD" = var.immich_db_password
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
  pool        = local.root_pool

  file {
    content            = ""
    target_path        = "/matplotlib/.keep"
    create_directories = true
    directory_mode     = "0700"
    uid                = local.app_uid
    gid                = local.app_gid
    mode               = "0600"
  }
}


resource "incus_instance" "immich_machine_learning" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-machine-learning"
  image       = "oci-ghcr:immich-app/immich-machine-learning:v3.2.2-openvino@sha256:4013ec28ccf6344d7ae24554743a116d7f61124b98858f5646a401d5c5df12e2"
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
  pool        = local.root_pool

  lifecycle {
    prevent_destroy = true
  }
}


resource "incus_instance" "immich_server" {
  remote      = var.incus_remote
  project     = local.project
  name        = "immich-server"
  image       = "oci-ghcr:immich-app/immich-server:v3.2.2@sha256:79cc1623323d5894922686d8743b4780181428f98eecbfb58ce12c41ef02d1ea"
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
    "environment.DB_USERNAME"                 = var.immich_db_username
    "environment.DB_PASSWORD"                 = var.immich_db_password
    "environment.DB_DATABASE_NAME"            = var.immich_db_name
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
    name = "gpu"
    type = "gpu"

    properties = {
      "mode" = "0666"
    }
  }
}

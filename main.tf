### Datasource
data "yandex_client_config" "client" {}

### Locals
locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
}

### Trail
resource "yandex_audit_trails_trail" "this" {
  name               = var.name
  folder_id          = local.folder_id
  description        = var.description
  labels             = var.labels
  service_account_id = var.service_account_id

  dynamic "storage_destination" {
    for_each = var.destination_type == "storage" ? [1] : []
    content {
      bucket_name   = module.bucket_audit[0].bucket_name
      object_prefix = var.object_prefix
    }
  }

  dynamic "logging_destination" {
    for_each = var.destination_type == "logging" ? [1] : []
    content {
      log_group_id = yandex_logging_group.this[0].id
    }
  }

  dynamic "data_stream_destination" {
    for_each = var.destination_type == "data_stream" ? [1] : []
    content {
      database_id = yandex_ydb_database_serverless.this[0].id
      stream_name = yandex_ydb_topic.topic[0].name
    }
  }

  filtering_policy {
    dynamic "management_events_filter" {
      for_each = var.management_events_filter
      content {
        resource_scope {
          resource_id   = management_events_filter.value.resource_id
          resource_type = management_events_filter.value.resource_type
        }
      }
    }

    dynamic "data_events_filter" {
      for_each = var.data_events_filter
      content {
        service = data_events_filter.value.service
        resource_scope {
          resource_id   = data_events_filter.value.resource_id
          resource_type = data_events_filter.value.resource_type
        }
        included_events = lookup(data_events_filter.value, "included_events", null)
        excluded_events = lookup(data_events_filter.value, "excluded_events", null)
      }
    }
  }
}

### Auto Logging group
resource "yandex_logging_group" "this" {
  count            = var.destination_type == "logging" ? 1 : 0
  name             = "for-audit-trail-${var.name}"
  folder_id        = local.folder_id
  retention_period = var.retention_period_log_group
  labels           = var.labels
  description      = "For Audit Trail ${var.name}"
}

resource "yandex_resourcemanager_folder_iam_member" "log_group" {
  count     = var.destination_type == "logging" ? 1 : 0
  folder_id = local.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${var.service_account_id}"
}

### Auto S3
resource "random_string" "unique_id" {
  count   = var.destination_type == "storage" ? 1 : 0
  length  = 4
  upper   = false
  lower   = true
  numeric = true
  special = false
}

module "bucket_audit" {
  count       = var.destination_type == "storage" ? 1 : 0
  source      = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git?ref=e4017d7"
  bucket_name = "audit-trail-${var.name}-${random_string.unique_id[0].result}"
  folder_id   = local.folder_id
  versioning = {
    enabled = true
  }
  lifecycle_rule = [
    {
      enabled = true
      id      = "cleanupoldlogs"
      expiration = {
        days = var.retention_period_bucket
      }
  }]
  server_side_encryption_configuration = {
    enabled = true
  }
  force_destroy = true
}

resource "yandex_resourcemanager_folder_iam_member" "auto_storage" {
  count     = var.destination_type == "storage" ? 1 : 0
  folder_id = local.folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${var.service_account_id}"
}

resource "yandex_kms_symmetric_key_iam_binding" "auto_storage" {
  count            = var.destination_type == "storage" ? 1 : 0
  symmetric_key_id = module.bucket_audit[0].kms_master_key_id
  role             = "kms.keys.encrypter"
  members          = ["serviceAccount:${var.service_account_id}"]
}

### Auto Data Streams coming

resource "yandex_ydb_database_serverless" "this" {
  count               = var.destination_type == "data_stream" ? 1 : 0
  name                = "for-audit-trail-${var.name}"
  folder_id           = local.folder_id
  description         = "Data Streams for audit trail ${var.name}"
  deletion_protection = false
  labels              = var.labels
}

resource "null_resource" "wait_for_ydb" {
  count = var.destination_type == "data_stream" ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 5"
  }
}

resource "yandex_ydb_topic" "topic" {
  count             = var.destination_type == "data_stream" ? 1 : 0
  database_endpoint = yandex_ydb_database_serverless.this[0].ydb_full_endpoint
  name              = "for-audit-trail-${var.name}"
  depends_on        = [yandex_ydb_database_serverless.this, null_resource.wait_for_ydb]
}

resource "yandex_resourcemanager_folder_iam_member" "ydb" {
  count     = var.destination_type == "data_stream" ? 1 : 0
  folder_id = local.folder_id
  role      = "ydb.editor"
  member    = "serviceAccount:${var.service_account_id}"
}

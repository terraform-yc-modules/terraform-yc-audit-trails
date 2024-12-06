output "trail_id" {
  description = "ID of the created audit trail"
  value       = yandex_audit_trails_trail.this.id
}

output "bucket_name" {
  description = "ID of the created for audit trail storage bucket"
  value       = try(module.bucket_audit[0].bucket_name, null)
}

output "logging_group_id" {
  description = "ID of the created for audit trail logging group"
  value       = try(yandex_logging_group.this[0].id, null)
}

output "data_stream_id" {
  description = "ID of the created for audit trail data stream"
  value       = try(yandex_ydb_topic.topic[0].id, null)
}

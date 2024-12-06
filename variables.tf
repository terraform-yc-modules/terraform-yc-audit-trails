variable "name" {
  description = "Name of the trail."
  type        = string
}

variable "folder_id" {
  description = "ID of the folder to which the trail belongs."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the trail."
  type        = string
  default     = "Created by yandex terraform module"
}

variable "labels" {
  description = "Labels defined by the user."
  type        = map(string)
  default = {
    created_by = "yandex-terraform-module"
  }
}

variable "service_account_id" {
  description = "ID of the IAM service account that is used by the trail."
  type        = string
}

variable "destination_type" {
  description = "Type of destination: 'storage', 'logging', or 'data_stream'."
  type        = string
  validation {
    condition     = contains(["storage", "logging", "data_stream"], var.destination_type)
    error_message = "destination_type must be one of 'storage', 'logging', or 'data_stream'."
  }
}

variable "object_prefix" {
  description = "Additional prefix of the uploaded objects (if using storage_destination)."
  type        = string
  default     = null
}

variable "management_events_filter" {
  description = "Optional list of management events filters."
  type = list(object({
    resource_id   = string
    resource_type = string
  }))
  default = []
}

variable "data_events_filter" {
  description = "Optional list of data events filters."
  type = list(object({
    service         = string
    resource_id     = string
    resource_type   = string
    included_events = optional(list(string), [])
    excluded_events = optional(list(string), [])
  }))
  default = []
}

variable "retention_period_bucket" {
  default     = 1095
  description = "Number of days to keep logs in the bucket"
  type        = number
}

variable "retention_period_log_group" {
  default     = "720h0m0s"
  description = "Number of hours to keep logs in logging group."
  type        = string
}

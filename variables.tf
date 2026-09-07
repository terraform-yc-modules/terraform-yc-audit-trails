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
  description = "Optional list of management events filters. Use resource_scopes to monitor multiple resources and include_rules or exclude_rules to filter fields within events."
  type = list(object({
    resource_id   = optional(string)
    resource_type = optional(string)
    resource_scopes = optional(list(object({
      resource_id   = string
      resource_type = string
    })), [])
    include_rules = optional(list(object({
      conditions = list(object({
        field    = string
        operator = string
        values   = list(string)
      }))
    })), [])
    exclude_rules = optional(list(object({
      conditions = list(object({
        field    = string
        operator = string
        values   = list(string)
      }))
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for filter in var.management_events_filter :
      (filter.resource_id == null) == (filter.resource_type == null) &&
      (filter.resource_id != null || length(filter.resource_scopes) > 0) &&
      length(filter.include_rules) <= 64 &&
      length(filter.exclude_rules) <= 64 &&
      alltrue([for rule in concat(filter.include_rules, filter.exclude_rules) : length(rule.conditions) >= 1 && length(rule.conditions) <= 64])
    ])
    error_message = "Each management events filter needs one legacy resource_id/resource_type pair or resource_scopes. Each include or exclude rule must have 1-64 conditions, and no more than 64 rules of either kind are allowed."
  }
}

variable "data_events_filter" {
  description = "Optional list of data events filters. Use resource_scopes to monitor multiple resources and include_rules or exclude_rules to filter fields within events."
  type = list(object({
    service       = string
    resource_id   = optional(string)
    resource_type = optional(string)
    resource_scopes = optional(list(object({
      resource_id   = string
      resource_type = string
    })), [])
    included_events = optional(list(string), [])
    excluded_events = optional(list(string), [])
    include_rules = optional(list(object({
      conditions = list(object({
        field    = string
        operator = string
        values   = list(string)
      }))
    })), [])
    exclude_rules = optional(list(object({
      conditions = list(object({
        field    = string
        operator = string
        values   = list(string)
      }))
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for filter in var.data_events_filter :
      (filter.resource_id == null) == (filter.resource_type == null) &&
      (filter.resource_id != null || length(filter.resource_scopes) > 0) &&
      !(length(filter.included_events) > 0 && length(filter.excluded_events) > 0) &&
      length(filter.include_rules) <= 64 &&
      length(filter.exclude_rules) <= 64 &&
      alltrue([for rule in concat(filter.include_rules, filter.exclude_rules) : length(rule.conditions) >= 1 && length(rule.conditions) <= 64])
    ])
    error_message = "Each data events filter needs one legacy resource_id/resource_type pair or resource_scopes; included_events and excluded_events are mutually exclusive. Each include or exclude rule must have 1-64 conditions, and no more than 64 rules of either kind are allowed."
  }
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

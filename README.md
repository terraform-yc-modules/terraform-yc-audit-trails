# Yandex Cloud Audit Trails

## Requirements
Use Service Account for Audit Trails with **audit-trails.viewer** role for the organization/cloud/folder.

## Features

- Create a Audit Trail with the following destinations:
  - Storage
  - Logging group
  - Data Stream
- Create choosed destinations automatically
- Easy to add events filters for control and data events
- Easy to use in other resources via outputs

### Example

See [examples section](./examples/)

### Configure Terraform for Yandex Cloud

- Install [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud

```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.134.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.134.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket_audit"></a> [bucket\_audit](#module\_bucket\_audit) | git::https://github.com/terraform-yc-modules/terraform-yc-s3.git | e4017d7 |

## Resources

| Name | Type |
|------|------|
| [random_string.unique_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [yandex_audit_trails_trail.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/audit_trails_trail) | resource |
| [yandex_kms_symmetric_key_iam_binding.auto_storage](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kms_symmetric_key_iam_binding) | resource |
| [yandex_logging_group.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/logging_group) | resource |
| [yandex_resourcemanager_folder_iam_member.auto_storage](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_resourcemanager_folder_iam_member.log_group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/resourcemanager_folder_iam_member) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_events_filter"></a> [data\_events\_filter](#input\_data\_events\_filter) | Optional list of data events filters. | <pre>list(object({<br>    service         = string<br>    resource_id     = string<br>    resource_type   = string<br>    included_events = optional(list(string), [])<br>    excluded_events = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_database_id"></a> [database\_id](#input\_database\_id) | ID of the database (if using data\_stream\_destination). | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the trail. | `string` | `""` | no |
| <a name="input_destination_type"></a> [destination\_type](#input\_destination\_type) | Type of destination: 'storage', 'logging', or 'data\_stream'. | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | ID of the folder to which the trail belongs. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels defined by the user. | `map(string)` | <pre>{<br>  "created_by": "yandex-terraform-module"<br>}</pre> | no |
| <a name="input_management_events_filter"></a> [management\_events\_filter](#input\_management\_events\_filter) | Optional list of management events filters. | <pre>list(object({<br>    resource_id   = string<br>    resource_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the trail. | `string` | n/a | yes |
| <a name="input_object_prefix"></a> [object\_prefix](#input\_object\_prefix) | Additional prefix of the uploaded objects (if using storage\_destination). | `string` | `null` | no |
| <a name="input_retention_period_bucket"></a> [retention\_period\_bucket](#input\_retention\_period\_bucket) | Number of days to keep logs in the bucket | `number` | `1095` | no |
| <a name="input_retention_period_log_group"></a> [retention\_period\_log\_group](#input\_retention\_period\_log\_group) | Number of hours to keep logs in logging group. | `string` | `"720h0m0s"` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | ID of the IAM service account that is used by the trail. | `string` | n/a | yes |
| <a name="input_stream_name"></a> [stream\_name](#input\_stream\_name) | Name of the stream (if using data\_stream\_destination). | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | ID of the created for audit trail storage bucket |
| <a name="output_logging_group_id"></a> [logging\_group\_id](#output\_logging\_group\_id) | ID of the created for audit trail logging group |
| <a name="output_trail_id"></a> [trail\_id](#output\_trail\_id) | ID of the created audit trail |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

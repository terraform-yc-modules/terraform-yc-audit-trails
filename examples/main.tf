module "at" {
  source           = "../"
  destination_type = "logging" # or storage
  management_events_filter = [
    { resource_id = var.folder_id
    resource_type = "resource-manager.folder" }
  ]
  data_events_filter = [
    {
      service       = "dns"
      resource_id   = var.folder_id
      resource_type = "resource-manager.folder"

    },
    {
      service         = "mdb.postgresql"
      resource_id     = var.folder_id
      resource_type   = "resource-manager.folder"
      excluded_events = ["yandex.cloud.audit.mdb.postgresql.CreateUser"]
    },
  ]

  name = "testy"

  service_account_id = yandex_iam_service_account.sa.id
  depends_on         = [yandex_resourcemanager_folder_iam_member.sa]
}

resource "yandex_iam_service_account" "sa" {
  name      = "audit-trails-sa"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa" {
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
  role      = "audit-trails.viewer"
}

variable "folder_id" {
  description = "The ID of the folder"
  type        = string
}


# database_id        = ""
# description        = ""
# stream_name              = ""
# object_prefix            = ""
destination_type = "storage"
# folder_id          = ""
# labels = {
#   "created_by": "yandex-terraform-module"
# }
management_events_filter = [
  { resource_id = "b1g1tli4sc25nie2c5g1"
  resource_type = "resource-manager.folder" }
]
data_events_filter = [
  {
    service       = "dns"
    resource_id   = "b1g1tli4sc25nie2c5g1"
    resource_type = "resource-manager.folder"

  },
  {
    service         = "mdb.postgresql"
    resource_id     = "b1g1tli4sc25nie2c5g1"
    resource_type   = "resource-manager.folder"
    excluded_events = ["yandex.cloud.audit.mdb.postgresql.CreateUser"]
  },
]

name = "testy"

service_account_id = "ajehc4jkgh2e203959q4"

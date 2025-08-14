variable "elasticsearch_endpoint" {}
variable "elasticsearch_management_api_key" {}
module "elasticsearch" {
  source  = "upmaru/base/tama//modules/elasticsearch"
  version = "0.2.29"

  name           = "Elasticsearch"
  endpoint       = var.elasticsearch_endpoint
  schema_version = "1.0.0"
  api_key        = var.elasticsearch_management_api_key
}

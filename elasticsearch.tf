variable "elasticsearch_endpoint" {}
variable "elasticsearch_management_api_key" {}
module "elasticsearch" {
  source  = "upmaru/base/tama//modules/elasticsearch"
  version = "0.2.37"

  depends_on = [
    module.global
  ]

  name           = "Elasticsearch"
  schema_version = "1.0.0"

  endpoint = var.elasticsearch_endpoint
  api_key  = var.elasticsearch_management_api_key

  index_mapping_generation_model_id = module.xai.model_ids["grok-3-mini"]
}

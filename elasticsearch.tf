variable "elasticsearch_endpoint" {}
variable "elasticsearch_management_api_key" {}
module "elasticsearch" {
  source  = "upmaru/base/tama//modules/elasticsearch"
  version = "0.4.0"

  depends_on = [
    module.global.schemas
  ]

  name           = "Elasticsearch"
  schema_version = "1.0.0"

  endpoint = var.elasticsearch_endpoint
  api_key  = var.elasticsearch_management_api_key

  index_mapping_generation_model_id          = module.openai.model_ids.gpt-5
  index_mapping_generation_model_temperature = 1.0
  index_mapping_generation_model_parameters = jsonencode({
    reasoning_effort = "low"
  })
}

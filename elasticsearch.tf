module "elasticsearch" {
  source  = "upmaru/base/tama//modules/elasticsearch"
  version = "0.2.17"

  name           = "Elasticsearch"
  endpoint       = "https://elasticsearch.arrakis.upmaru.network"
  schema_version = "1.0.0"
  api_key        = var.elasticsearch_management_api_key
}

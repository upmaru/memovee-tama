variable "tmdb_api_key" {}
variable "elasticsearch_movie_db_api_key" {}
module "movie-db" {
  source = "./movie-db"

  depends_on = [module.global]

  tmdb_api_key     = var.tmdb_api_key
  tmdb_openapi_url = "https://developer.themoviedb.org/openapi/64542913e1f86100738e227f"

  elasticsearch_endpoint         = var.elasticsearch_endpoint
  elasticsearch_api_key          = var.elasticsearch_movie_db_api_key
  elasticsearch_space_id         = module.elasticsearch.space_id
  elasticsearch_specification_id = module.elasticsearch.specification_id
  elasticsearch_query_schema     = module.elasticsearch.query_schema

  generate_description_model_id = module.openai.model_ids.gpt-5-nano
  generate_description_model_parameters = jsonencode({
    reasoning_effort = "low"
    service_tier     = "flex"
  })

  generate_setting_model_id = module.openai.model_ids.gpt-5-nano
  generate_setting_model_parameters = jsonencode({
    reasoning_effort = "low"
    service_tier     = "flex"
  })
}

module "index-mapping-generation" {
  source = "./index-mapping"

  depends_on = [module.global, module.movie-db]

  movie_db_space_id      = module.movie-db.space_id
  elasticsearch_space_id = module.elasticsearch.space_id
}

module "index-definition-generation" {
  source = "./index-definition"

  depends_on = [module.global, module.movie-db]

  movie_db_space_id      = module.movie-db.space_id
  tmdb_specification_id  = module.movie-db.tmdb_specification_id
  elasticsearch_space_id = module.elasticsearch.space_id

  index_definition_generation_model_id          = module.openai.model_ids.gpt-5-mini
  index_definition_generation_model_temperature = 1.0
  index_definition_generation_model_parameters = jsonencode({
    reasoning_effort = "high"
  })
}

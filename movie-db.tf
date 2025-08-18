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
}

module "index-definition-generation" {
  source = "./index-definition"

  depends_on = [module.global]

  movie_db_space_id      = module.movie-db.space_id
  tmdb_specification_id  = module.movie-db.tmdb_specification_id
  elasticsearch_space_id = module.elasticsearch.space_id
  model_id               = module.xai.model_ids["grok-3-mini"]
}

module "index-mapping-generation" {
  source = "./index-mapping"

  depends_on = [module.global]

  movie_db_space_id      = module.movie-db.space_id
  elasticsearch_space_id = module.elasticsearch.space_id
}

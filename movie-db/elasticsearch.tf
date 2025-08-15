resource "tama_specification" "movie-db-query-elasticsearch" {
  space_id = tama_space.movie-db.id

  version  = "1.0.0"
  endpoint = var.elasticsearch_endpoint
  schema   = var.elasticsearch_query_schema

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

resource "tama_source_identity" "movie-db-query-elasticsearch" {
  specification_id = tama_specification.movie-db-query-elasticsearch.id
  identifier       = "ApiKey"

  api_key = var.elasticsearch_api_key

  validation {
    path   = "/_cluster/health"
    method = "GET"
    codes  = [200]
  }

  wait_for {
    field {
      name = "current_state"
      in   = ["active", "failed"]
    }
  }
}

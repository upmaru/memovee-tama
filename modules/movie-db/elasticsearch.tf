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

data "tama_class" "text-based-vector-search" {
  specification_id = tama_specification.movie-db-query-elasticsearch.id
  name             = "text-based-vector-search"
}

resource "tama_class_corpus" "vector-search" {
  class_id = data.tama_class.text-based-vector-search.id
  name     = "Vector Search"
  template = file("${path.module}/vector-search.liquid")
}

data "tama_class" "query-and-sort-based-search" {
  specification_id = tama_specification.movie-db-query-elasticsearch.id
  name             = "query-and-sort-based-search"
}

resource "tama_class_corpus" "standard-search" {
  class_id = data.tama_class.query-and-sort-based-search.id
  name     = "Standard Search"
  template = file("${path.module}/standard-search.liquid")
}

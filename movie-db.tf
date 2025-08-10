resource "tama_space" "movie-db" {
  name = "Movie DB"
  type = "component"
}

locals {
  tmdb_openapi_url = "https://developer.themoviedb.org/openapi/64542913e1f86100738e227f"
}

data "http" "tmdb" {
  url = local.tmdb_openapi_url
}

resource "tama_specification" "tmdb" {
  space_id = tama_space.movie-db.id

  endpoint = local.tmdb_openapi_url
  version  = "3.0.0"
  schema   = jsonencode(jsondecode(data.http.tmdb.response_body))

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

variable "tmdb_api_key" {}
resource "tama_source_identity" "tmdb" {
  specification_id = tama_specification.tmdb.id
  identifier       = "sec0"

  api_key = var.tmdb_api_key

  validation {
    path   = "/3/authentication"
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


resource "tama_specification" "movie-db-query-elasticsearch" {
  space_id = tama_space.movie-db.id
  version  = "1.0.0"
  endpoint = var.elasticsearch_endpoint
  schema   = module.elasticsearch.query_schema

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

variable "elasticsearch_movie_db_api_key" {}
resource "tama_source_identity" "movie-db-query-elasticsearch" {
  specification_id = tama_specification.movie-db-query-elasticsearch.id
  identifier       = "ApiKey"

  api_key = var.elasticsearch_movie_db_api_key

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

data "tama_source" "tmdb-api" {
  specification_id = tama_specification.tmdb.id
  slug             = "tmdb-api"
}

resource "tama_source_limit" "tmdb-api" {
  source_id   = data.tama_source.tmdb-api.id
  scale_count = 1
  scale_unit  = "seconds"
  value       = 40
}

# TODO replace this with extract-nested-properties module
# data "tama_class" "movie-credits" {
#   specification_id = tama_specification.tmdb.id
#   name             = "movie-credits"
# }

# resource "tama_chain" "extract-nested-properties" {
#   space_id = tama_space.movie-db.id
#   name     = "Extract Nested Properties"
# }

# resource "tama_modular_thought" "nested-properties-extraction" {
#   chain_id = tama_chain.extract-nested-properties.id
#   index    = 0
#   relation = "extraction"

#   module {
#     reference = "tama/classes/extraction"
#     parameters = jsonencode({
#       types = ["array"]
#       depth = 1
#     })
#   }
# }

# resource "tama_thought_path" "extract-nested-properties-movie-credits" {
#   thought_id      = tama_modular_thought.nested-properties-extraction.id
#   target_class_id = data.tama_class.movie-credits.id
# }

# resource "tama_node" "handle-movie-credits-nested-extraction" {
#   space_id = tama_space.movie-db.id
#   class_id = module.global.schemas["class-proxy-class"].id
#   chain_id = tama_chain.extract-nested-properties.id

#   type = "explicit"
# }

data "tama_class" "movie-details" {
  specification_id = tama_specification.tmdb.id
  name             = "movie-details"
}

resource "tama_class_corpus" "crawl-movie-details" {
  class_id = data.tama_class.movie-details.id
  name     = "Crawl Movie Details"
  template = file("${path.module}/movie-db/crawl-movie-details.liquid")
}

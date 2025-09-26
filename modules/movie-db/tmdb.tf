data "http" "tmdb" {
  url = var.tmdb_openapi_url
}

resource "tama_specification" "tmdb" {
  space_id = tama_space.movie-db.id

  endpoint = var.tmdb_openapi_url
  version  = "3.0.0"
  schema   = jsonencode(jsondecode(data.http.tmdb.response_body))

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

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

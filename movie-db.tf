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

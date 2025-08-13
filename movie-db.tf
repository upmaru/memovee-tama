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

module "extract-nested-properties-movie-db" {
  source  = "upmaru/base/tama//modules/extract-nested-properties"
  version = "0.2.26"

  depends_on = [module.global]

  class_names      = ["movie-credits"]
  specification_id = tama_specification.tmdb.id
  space_id         = tama_space.movie-db.id

  types = ["array"]
  depth = 1

  expected_class_names = [
    "movie-credits.cast",
    "movie-credits.crew"
  ]
}

locals {
  spread_class_ids = values(module.extract-nested-properties-movie-db.extracted_class_ids)
  cast_class_id    = module.extract-nested-properties-movie-db.extracted_class_ids["movie-credits.cast"]
  crew_class_id    = module.extract-nested-properties-movie-db.extracted_class_ids["movie-credits.crew"]
}

data "tama_class" "movie-details" {
  specification_id = tama_specification.tmdb.id
  name             = "movie-details"
}

data "tama_action" "get-movie-credits" {
  specification_id = tama_specification.tmdb.id
  identifier       = "movie-credits"
}

resource "tama_class_corpus" "movie-details-mapping" {
  class_id = data.tama_class.movie-details.id
  name     = "Crawl Movie Details"
  template = file("${path.module}/movie-db/movie-id-mapping.liquid")
}

module "crawl-movie-credits" {
  source  = "upmaru/base/tama//modules/crawler"
  version = "0.2.26"

  depends_on = [module.global]

  name            = "Crawl Movie Credits"
  space_id        = tama_space.movie-db.id
  origin_class_id = data.tama_class.movie-details.id

  request_input_corpus_id = tama_class_corpus.movie-details-mapping.id

  request_relation  = "get-movie-credits"
  request_action_id = data.tama_action.get-movie-credits.id

  response_relation = "create-movie-credits"

  validate_record = false
}

module "spread-cast-and-crew" {
  source  = "upmaru/base/tama//modules/spread"
  version = "0.2.26"

  depends_on = [module.global]

  name = "Spread Cast and Crew"

  space_id = tama_space.movie-db.id
  class_id = data.tama_class.movie-credits.id
  fields   = ["cast", "crew"]

  target_class_ids = local.spread_class_ids
}

data "tama_class" "movie-credits" {
  specification_id = tama_specification.tmdb.id
  name             = "movie-credits"
}

module "network-movie-credits" {
  source  = "upmaru/base/tama//modules/build-relations"
  version = "0.2.26"

  depends_on = [module.global]

  name     = "Network Movie Credits"
  space_id = tama_space.movie-db.id

  class_ids = [
    data.tama_class.movie-credits.id
  ]

  can_belong_to_class_ids = [
    data.tama_class.movie-details.id
  ]
}

module "network-cast-and-crew" {
  source  = "upmaru/base/tama//modules/build-relations"
  version = "0.2.26"

  depends_on = [module.global]

  name     = "Network Cast and Crew"
  space_id = tama_space.movie-db.id

  class_ids = [
    local.crew_class_id,
    local.cast_class_id
  ]

  can_belong_to_class_ids = [
    data.tama_class.movie-credits.id
  ]
}

data "tama_class" "person-details" {
  specification_id = tama_specification.tmdb.id
  name             = "person-details"
}

module "network-person-details" {
  source  = "upmaru/base/tama//modules/build-relations"
  version = "0.2.26"

  depends_on = [module.global]

  name     = "Network Person Details"
  space_id = tama_space.movie-db.id

  class_ids = [
    data.tama_class.person-details.id,
  ]

  can_belong_to_class_ids = [
    local.cast_class_id,
    local.crew_class_id
  ]
}

resource "tama_class_corpus" "movie-details-cast-mapping" {
  class_id = local.cast_class_id
  name     = "Crawl Cast Details"
  template = file("${path.module}/movie-db/person-id-mapping.liquid")
}

resource "tama_class_corpus" "movie-details-crew-mapping" {
  class_id = local.crew_class_id
  name     = "Crawl Crew Details"
  template = file("${path.module}/movie-db/person-id-mapping.liquid")
}

data "tama_action" "get-person-details" {
  specification_id = tama_specification.tmdb.id
  method           = "GET"
  path             = "/3/person/{person_id}"
}

module "crawl-cast-details" {
  source  = "upmaru/base/tama//modules/crawler"
  version = "0.2.26"

  depends_on = [module.global]

  name            = "Crawl Cast Details"
  space_id        = tama_space.movie-db.id
  origin_class_id = local.cast_class_id

  request_input_corpus_id = tama_class_corpus.movie-details-cast-mapping.id

  request_relation  = "get-cast-person-details"
  request_action_id = data.tama_action.get-person-details.id

  response_relation = "create-cast-person-details"

  validate_record = false
}

module "crawl-crew-details" {
  source  = "upmaru/base/tama//modules/crawler"
  version = "0.2.26"

  depends_on = [module.global]

  name            = "Crawl Crew Details"
  space_id        = tama_space.movie-db.id
  origin_class_id = local.crew_class_id

  request_input_corpus_id = tama_class_corpus.movie-details-crew-mapping.id

  request_relation  = "get-crew-person-details"
  request_action_id = data.tama_action.get-person-details.id

  response_relation = "create-crew-person-details"

  validate_record = false
}

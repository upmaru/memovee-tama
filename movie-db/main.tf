data "tama_space" "global" {
  id = "global"
}

data "tama_class" "answer" {
  space_id = data.tama_space.global.id
  name     = "answer"
}

data "tama_class_corpus" "answer-content" {
  class_id = data.tama_class.answer.id
  slug     = "answer-content"
}

resource "tama_space" "movie-db" {
  name = "Movie DB"
  type = "component"
}

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
  version = "0.2.34"

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
  template = file("movie-db/movie-id-mapping.liquid")
}

module "crawl-movie-credits" {
  source  = "upmaru/base/tama//modules/crawler"
  version = "0.2.34"

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
  version = "0.2.34"

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
  version = "0.2.34"

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
  version = "0.2.34"

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
  version = "0.2.34"

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
  template = file("movie-db/person-id-mapping.liquid")
}

resource "tama_class_corpus" "movie-details-crew-mapping" {
  class_id = local.crew_class_id
  name     = "Crawl Crew Details"
  template = file("movie-db/person-id-mapping.liquid")
}

data "tama_action" "get-person-details" {
  specification_id = tama_specification.tmdb.id
  method           = "GET"
  path             = "/3/person/{person_id}"
}

module "crawl-cast-details" {
  source  = "upmaru/base/tama//modules/crawler"
  version = "0.2.34"

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
  version = "0.2.34"

  name            = "Crawl Crew Details"
  space_id        = tama_space.movie-db.id
  origin_class_id = local.crew_class_id

  request_input_corpus_id = tama_class_corpus.movie-details-crew-mapping.id

  request_relation  = "get-crew-person-details"
  request_action_id = data.tama_action.get-person-details.id

  response_relation = "create-crew-person-details"

  validate_record = false
}

data "tama_action" "get-person-combined-credits" {
  specification_id = tama_specification.tmdb.id
  method           = "GET"
  path             = "/3/person/{person_id}/combined_credits"
}

resource "tama_class_corpus" "person-details-mapping" {
  class_id = data.tama_class.person-details.id
  name     = "Crawl Person Detail Mapping"
  template = file("movie-db/person-id-mapping.liquid")
}

module "crawl-person-credits" {
  source  = "upmaru/base/tama//modules/crawler"
  version = "0.2.34"

  name            = "Crawl Person Combined Credits"
  space_id        = tama_space.movie-db.id
  origin_class_id = data.tama_class.person-details.id

  request_input_corpus_id = tama_class_corpus.person-details-mapping.id

  request_relation  = "get-person-combined-credits"
  request_action_id = data.tama_action.get-person-combined-credits.id

  response_relation = "create-person-combined-credits"

  validate_record = false
}

data "tama_class" "person-combined-credits" {
  specification_id = tama_specification.tmdb.id
  name             = "person-combined-credits"
}

module "network-person-credits" {
  source  = "upmaru/base/tama//modules/build-relations"
  version = "0.2.34"

  name     = "Network Person Credits"
  space_id = tama_space.movie-db.id

  class_ids = [
    data.tama_class.person-combined-credits.id,
  ]

  can_belong_to_class_ids = [
    data.tama_class.person-details.id
  ]
}

module "extract-embed-movie-overview" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.2.34"

  name      = "Extract and Embed Movie Overview"
  space_id  = tama_space.movie-db.id
  relations = ["overview"]

  embeddable_class_ids = [
    data.tama_class.movie-details.id
  ]
}

module "extract-embed-person-biography" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.2.34"

  name      = "Extract and Embed Person Biography"
  space_id  = tama_space.movie-db.id
  relations = ["biography"]

  embeddable_class_ids = [
    data.tama_class.person-details.id
  ]
}

resource "tama_prompt" "generate-description" {
  space_id = tama_space.movie-db.id
  name     = "Generate Description"
  role     = "user"
  content  = file("movie-db/generate-description.md")
}

resource "tama_prompt" "generate-setting" {
  space_id = tama_space.movie-db.id
  name     = "Generate Setting"
  role     = "user"
  content  = file("movie-db/setting-extraction.md")
}

resource "tama_class" "movie-setting" {
  space_id = tama_space.movie-db.id

  schema_json = jsonencode(jsondecode(file("movie-db/setting.json")))
}

resource "tama_class_corpus" "setting-embedding-corpus" {
  class_id = tama_class.movie-setting.id
  name     = "Setting Embedding Corpus"
  template = "{{ data.reason }}"
}

resource "tama_chain" "generate-description-and-setting-and-embed" {
  space_id = tama_space.movie-db.id
  name     = "Generate Description and Setting and Embed"
}

resource "tama_modular_thought" "generate-description" {
  chain_id = tama_chain.generate-description-and-setting-and-embed.id

  index    = 0
  relation = "description"

  module {
    reference = "tama/agentic/generate"
  }
}

resource "tama_thought_context" "generate-description-context" {
  thought_id = tama_modular_thought.generate-description.id
  layer      = 0
  prompt_id  = tama_prompt.generate-description.id
}

data "tama_class_corpus" "movie-details-default-json" {
  class_id = data.tama_class.movie-details.id
  slug     = "entity-json-schema"
}

resource "tama_thought_context_input" "entity-corpus-input" {
  thought_context_id = tama_thought_context.generate-description-context.id
  type               = "entity"
  class_corpus_id    = data.tama_class_corpus.movie-details-default-json.id
}

resource "tama_modular_thought" "generate-setting" {
  chain_id = tama_chain.generate-description-and-setting-and-embed.id

  index    = 1
  relation = "setting"

  module {
    reference = "tama/agentic/generate"
  }
}

resource "tama_thought_context" "generate-setting-context" {
  thought_id = tama_modular_thought.generate-setting.id
  layer      = 0
  prompt_id  = tama_prompt.generate-setting.id
}

resource "tama_thought_context_input" "generate-setting-context-input" {
  thought_context_id = tama_thought_context.generate-setting-context.id
  type               = "concept"
  class_corpus_id    = data.tama_class_corpus.answer-content.id
}

resource "tama_modular_thought" "embed-description" {
  chain_id = tama_chain.generate-description-and-setting-and-embed.id

  index    = 2
  relation = "embed-description"

  module {
    reference = "tama/concepts/embed"
    parameters = jsonencode({
      relation = "description"
    })
  }
}

resource "tama_thought_module_input" "embed-description-input" {
  thought_id      = tama_modular_thought.embed-description.id
  type            = "concept"
  class_corpus_id = data.tama_class_corpus.answer-content.id
}

resource "tama_modular_thought" "embed-setting" {
  chain_id = tama_chain.generate-description-and-setting-and-embed.id

  index    = 3
  relation = "embed-setting"

  module {
    reference = "tama/concepts/embed"
    parameters = jsonencode({
      relation = "setting"
    })
  }
}

resource "tama_thought_module_input" "embed-setting-input" {
  thought_id      = tama_modular_thought.embed-setting.id
  type            = "concept"
  class_corpus_id = tama_class_corpus.setting-embedding-corpus.id
}

resource "tama_node" "handle-movie-details-embedding" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.movie-details.id
  chain_id = tama_chain.generate-description-and-setting-and-embed.id

  type = "reactive"
}

resource "tama_space_bridge" "movie-db-elasticsearch" {
  space_id        = tama_space.movie-db.id
  target_space_id = var.elasticsearch_space_id
}

resource "tama_class_corpus" "movie-details-indexing" {
  class_id = data.tama_class.movie-details.id
  name     = "Movie Details Indexing"
  template = file("movie-db/movie-details-indexing.liquid")
}

data "tama_action" "index-document" {
  specification_id = var.elasticsearch_specification_id
  method           = "PUT"
  path             = "/{index}/_doc/{id}"
}

resource "tama_chain" "index-movie-details" {
  space_id = tama_space.movie-db.id
  name     = "Index Movie Details"
}

resource "tama_modular_thought" "index-movie-details" {
  chain_id = tama_chain.index-movie-details.id

  index    = 0
  relation = "index-movie-details"

  module {
    reference = "tama/actions/caller"
  }
}

module "movie-details-preloader" {
  source  = "upmaru/base/tama//modules/initializer-preload"
  version = "0.2.34"

  thought_id = tama_modular_thought.index-movie-details.id
  class_id   = data.tama_class.movie-details.id
  index      = 0

  concept_relations  = ["description", "overview", "setting"]
  concept_embeddings = "include"
  concept_content = {
    action = "merge"
    merge = {
      location = "root"
      name     = "merge"
    }
  }

  children = [
    { class = "movie-credits", as = "object" }
  ]
}

resource "tama_thought_module_input" "index-movie-details" {
  thought_id      = tama_modular_thought.index-movie-details.id
  type            = "entity"
  class_corpus_id = tama_class_corpus.movie-details-indexing.id
}

resource "tama_thought_tool" "index-movie-details" {
  thought_id = tama_modular_thought.index-movie-details.id
  action_id  = data.tama_action.index-document.id
}

resource "tama_node" "index-movie-details-on-processed" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.movie-details.id
  chain_id = tama_chain.index-movie-details.id

  type = "reactive"
  on   = "processed"
}

resource "tama_node" "index-movie-details-explicit" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.movie-details.id
  chain_id = tama_chain.index-movie-details.id

  type = "explicit"
}

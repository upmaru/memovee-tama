resource "tama_chain" "this" {
  space_id = var.space_id
  name     = "Crawl Movie Credits"
}

resource "tama_modular_thought" "request" {
  chain_id = tama_chain.this.id

  index           = 0
  relation        = "crawl-movie-credits"
  output_class_id = var.action_call_class_id

  module {
    reference = "tama/actions/caller"
  }
}

resource "tama_class_corpus" "movie-details-mapping" {
  class_id = data.tama_class.movie-details.id
  name     = "Crawl Movie Details"
  template = file("${path.module}/movie-details-mapping.liquid")
}


resource "tama_thought_module_input" "this" {
  thought_id = tama_modular_thought.request.id

  type            = "entity"
  class_corpus_id = tama_class_corpus.movie-details-mapping.id
}

data "tama_action" "movie-credits" {
  specification_id = var.specification_id
  identifier       = "movie-credits"
}

resource "tama_thought_tool" "this" {
  thought_id = tama_modular_thought.request.id

  action_id = data.tama_action.movie-credits.id
}

resource "tama_modular_thought" "response" {
  chain_id = tama_chain.this.id

  index    = 1
  relation = "movie-credits-response"

  module {
    reference = "tama/actions/response"
    parameters = jsonencode({
      relation        = "crawl-movie-credits"
      identifier      = "id"
      validate_record = false
      process_entity  = true
    })
  }
}

resource "tama_thought_module_input" "input-action-call-json" {
  thought_id = tama_modular_thought.response.id

  type            = "concept"
  class_corpus_id = var.action_call_json_corpus_id
}

data "tama_class" "movie-details" {
  specification_id = var.specification_id
  name             = "movie-details"
}

resource "tama_node" "this" {
  space_id = var.space_id
  class_id = data.tama_class.movie-details.id
  chain_id = tama_chain.this.id

  type = "reactive"
}

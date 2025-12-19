resource "tama_prompt" "index-definition-generation" {
  space_id = var.movie_db_space_id
  name     = "Index Definition Generation"
  role     = "user"
  content  = file("${path.module}/prompt.md")
}

resource "tama_class" "index-definition" {
  space_id    = var.movie_db_space_id
  schema_json = jsonencode(jsondecode(file("${path.module}/schema.json")))
}

resource "tama_class_corpus" "index-definition-yaml" {
  class_id = tama_class.index-definition.id
  name     = "Index Definition YAML"
  template = file("${path.module}/template.liquid")
}

resource "tama_chain" "this" {
  space_id = var.movie_db_space_id
  name     = "Index Definition Generation"
}

resource "tama_modular_thought" "this" {
  chain_id        = tama_chain.this.id
  relation        = "index-definition"
  index           = 0
  output_class_id = tama_class.index-definition.id

  module {
    reference = "tama/agentic/generate"
    parameters = jsonencode({
      timeout_seconds = 1200
    })
  }
}

resource "tama_thought_initializer" "import" {
  thought_id = tama_modular_thought.this.id
  class_id   = data.tama_class.class-proxy.id

  reference = "tama/initializers/import"
  parameters = jsonencode({
    resources = [
      { type = "concept", relation = "mappings", scope = "entity" },
      { type = "concept", relation = "sample", scope = "entity" }
    ]
  })
}

locals {
  movie_db_index_definition_relation  = "movie-details-definition"
  person_db_index_definition_relation = "person-details-definition"
}

resource "tama_thought_path" "movie-details-definition" {
  thought_id      = tama_modular_thought.this.id
  target_class_id = data.tama_class.movie-details.id
  parameters = jsonencode({
    relation = local.movie_db_index_definition_relation
  })
}

resource "tama_thought_path" "person-details-definition" {
  thought_id      = tama_modular_thought.this.id
  target_class_id = data.tama_class.person-details.id
  parameters = jsonencode({
    relation = local.person_db_index_definition_relation
  })
}

resource "tama_thought_processor" "index-definition-generator" {
  thought_id = tama_modular_thought.this.id
  model_id   = var.index_definition_generation_model_id

  completion {
    temperature = var.index_definition_generation_model_temperature
    parameters  = var.index_definition_generation_model_parameters
  }
}

resource "tama_thought_context" "index-definition-generation-context" {
  thought_id = tama_modular_thought.this.id
  prompt_id  = tama_prompt.index-definition-generation.id
}

resource "tama_thought_context_input" "collection-sample" {
  thought_context_id = tama_thought_context.index-definition-generation-context.id
  type               = "concept"
  class_corpus_id    = data.tama_class_corpus.collection-sampling.id
}

resource "tama_thought_context_input" "elasticsearch-mapping" {
  thought_context_id = tama_thought_context.index-definition-generation-context.id
  type               = "concept"
  class_corpus_id    = data.tama_class_corpus.elasticsearch-mapping.id
}

resource "tama_modular_thought" "swap-querying-alias" {
  chain_id        = tama_chain.this.id
  relation        = "swap-querying-alias"
  index           = 1
  output_class_id = data.tama_class.action-call.id

  module {
    reference = "tama/actions/caller"
    parameters = jsonencode({
      relation = var.create_index_relation
    })
  }
}

resource "tama_thought_initializer" "import-create-index" {
  thought_id = tama_modular_thought.swap-querying-alias.id
  class_id   = data.tama_class.class-proxy.id

  reference = "tama/initializers/import"
  parameters = jsonencode({
    resources = [
      {
        type     = "concept"
        relation = var.create_index_relation
        scope    = "entity"
      }
    ]
  })
}

resource "tama_class_corpus" "swap-alias-request" {
  class_id = data.tama_class.action-call.id
  name     = "Swap Alias Request"
  template = file("${path.module}/swap-alias-request.liquid")
}

resource "tama_thought_module_input" "input-swap-alias-request" {
  thought_id      = tama_modular_thought.swap-querying-alias.id
  type            = "concept"
  class_corpus_id = tama_class_corpus.swap-alias-request.id
}

data "tama_action" "aliases" {
  specification_id = var.elasticsearch_specification_id
  method           = "POST"
  path             = "/_aliases"
}

resource "tama_thought_tool" "aliases-action" {
  thought_id = tama_modular_thought.swap-querying-alias.id
  action_id  = data.tama_action.aliases.id
}

resource "tama_node" "handle-index-definition-generation" {
  space_id = var.movie_db_space_id
  class_id = data.tama_class.class-proxy.id
  chain_id = tama_chain.this.id

  type = "reactive"
  on   = "processed"
}

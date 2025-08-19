resource "tama_prompt" "index-definition-generation" {
  space_id = var.movie_db_space_id
  name     = "Index Definition Generation"
  role     = "system"
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
  model_id   = var.model_id

  completion_config {
    temperature = 0.0
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

resource "tama_node" "handle-index-definition-generation" {
  space_id = var.movie_db_space_id
  class_id = data.tama_class.class-proxy.id
  chain_id = tama_chain.this.id

  type = "reactive"
  on   = "processed"
}

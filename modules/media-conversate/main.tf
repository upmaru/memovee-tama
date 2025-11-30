resource "tama_chain" "this" {
  space_id = var.media_conversation_space_id
  name     = var.name
}

//
// Browse Media Tooling
//
resource "tama_modular_thought" "tooling" {
  chain_id        = tama_chain.this.id
  index           = 0
  relation        = "search-tooling"
  output_class_id = data.tama_class.tool-call.id

  module {
    reference = "tama/agentic/tooling"
    parameters = jsonencode({
      consecutive_limit = 5
      thread = {
        limit   = var.thread_limit
        classes = var.thread_classes
        relations = {
          routing = var.routing_thought_relation
          focus   = ["tooling", "search-tooling", "reply"]
        }
      }
    })
  }
}

resource "tama_thought_context" "tooling" {
  thought_id = tama_modular_thought.tooling.id
  prompt_id  = var.tooling_prompt_id
}

resource "tama_thought_context_input" "tooling-metadata" {
  thought_context_id = tama_thought_context.tooling.id
  type               = "metadata"
  class_corpus_id    = data.tama_class_corpus.base-context-metadata.id
}

resource "tama_thought_context_input" "tooling-index-definition" {
  thought_context_id = tama_thought_context.tooling.id
  type               = "concept"
  class_corpus_id    = data.tama_class_corpus.index-definition-yaml.id
}

resource "tama_thought_processor" "tool-calling-model" {
  thought_id = tama_modular_thought.tooling.id
  model_id   = var.tool_call_model_id

  completion {
    temperature = var.tool_call_model_temperature
    tool_choice = var.tool_call_tool_choice
    parameters  = var.tool_call_model_parameters
  }
}

resource "tama_thought_tool" "query-elasticsearch" {
  thought_id = tama_modular_thought.tooling.id
  action_id  = data.tama_action.query-elasticsearch.id
}

resource "tama_thought_tool_initializer" "import-index-definition" {
  thought_tool_id = tama_thought_tool.query-elasticsearch.id
  index           = 0
  reference       = "tama/initializers/import"
  parameters = jsonencode({
    resources = [
      {
        type     = "concept"
        relation = var.index_definition_relation
        scope    = "space"
      }
    ]
  })
}

resource "tama_thought_tool_input" "vector-search-request-body" {
  thought_tool_id = tama_thought_tool.query-elasticsearch.id
  type            = "body"
  class_corpus_id = data.tama_class_corpus.vector-search-request-body.id
}

resource "tama_thought_tool_input" "standard-search-request-body" {
  thought_tool_id = tama_thought_tool.query-elasticsearch.id
  type            = "body"
  class_corpus_id = data.tama_class_corpus.standard-search-request-body.id
}

//
// Browse Media Forwarding
//
resource "tama_modular_thought" "forwarding" {
  chain_id        = tama_chain.this.id
  output_class_id = data.tama_class.forwarding.id
  index           = 1
  relation        = var.forwarding_relation

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forwarding" {
  thought_id      = tama_modular_thought.forwarding.id
  target_class_id = var.response_class_id
}

resource "tama_thought_path_directive" "artifact-directive" {
  thought_path_id   = tama_thought_path.forwarding.id
  prompt_id         = var.reply_artifact_prompt_id
  target_thought_id = var.reply_artifact_thought_id
}

resource "tama_thought_path_directive" "reply-directive" {
  thought_path_id   = tama_thought_path.forwarding.id
  prompt_id         = var.reply_prompt_id
  target_thought_id = var.reply_generation_thought_id
}

resource "tama_node" "this" {
  space_id = var.media_conversation_space_id
  class_id = var.target_class_id
  chain_id = tama_chain.this.id

  type = "reactive"
}

resource "tama_chain" "this" {
  space_id = var.media_conversation_space_id
  name     = var.name
}

locals {
  router_enabled           = try(var.router.enabled, false)
  router_parameters        = try(var.router.parameters, null)
  router_prompt_id         = try(var.router.prompt_id, null)
  router_model_id          = try(var.router.model_id, null)
  router_model_temperature = try(var.router.model_temperature, null)
  router_model_parameters  = try(var.router.model_parameters, null)
  router_routable_class_ids = distinct([
    for class_id in try(var.router.routable_class_ids, []) : class_id
    if class_id != var.response_class_id
  ])
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

  dynamic "faculty" {
    for_each = var.faculty_queue_id == null ? [] : [1]
    content {
      queue_id = var.faculty_queue_id
      priority = var.faculty_priority
    }
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
  output_class_id = local.router_enabled ? data.tama_class.message-routing.id : data.tama_class.forwarding.id
  index           = 1
  relation        = var.forwarding_relation

  module {
    reference  = local.router_enabled ? "tama/agentic/router" : "tama/concepts/forward"
    parameters = local.router_enabled ? jsonencode(local.router_parameters) : null
  }

  dynamic "faculty" {
    for_each = var.faculty_queue_id == null ? [] : [1]
    content {
      queue_id = var.faculty_queue_id
      priority = var.faculty_priority
    }
  }
}

resource "tama_thought_processor" "forwarding-router" {
  count = local.router_enabled ? 1 : 0

  thought_id = tama_modular_thought.forwarding.id
  model_id   = local.router_model_id

  completion {
    temperature = local.router_model_temperature
    parameters  = local.router_model_parameters
  }
}

resource "tama_thought_context" "forwarding-router" {
  count = local.router_enabled ? 1 : 0

  thought_id = tama_modular_thought.forwarding.id
  prompt_id  = local.router_prompt_id
}

resource "tama_thought_path" "forwarding" {
  thought_id      = tama_modular_thought.forwarding.id
  target_class_id = var.response_class_id
}

resource "tama_thought_path" "router" {
  for_each = local.router_enabled ? { for class_id in local.router_routable_class_ids : class_id => class_id } : {}

  thought_id      = tama_modular_thought.forwarding.id
  target_class_id = each.value
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

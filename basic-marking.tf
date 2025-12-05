resource "tama_chain" "handle-marking" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Marking"
}

resource "tama_prompt" "handle-marking" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Marking"
  role     = "system"
  content  = file("basic-marking/tooling.md")
}

module "manage-record-markings" {
  depends_on = [local.tool_call_class]

  source  = "upmaru/base/tama//modules/tooling"
  version = "0.4.9"

  chain_id = tama_chain.handle-marking.id

  relation = "tooling"
  index    = 0

  tool_call_model_id          = module.openai.model_ids["gpt-5.1-codex-mini"]
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = {
    reasoning = {
      effort = "low"
    }
  }

  tooling_parameters = {
    consecutive_limit = 5
    thread = {
      limit   = 5
      classes = module.memovee.thread_classes
      relations = {
        routing = "routing"
        focus   = ["tooling", "search-tooling", "reply"]
      }
    }
  }

  action_ids = [
    data.tama_action.create-record-markings.id,
    data.tama_action.list-record-markings.id
  ]

  contexts = {
    handle_marking = {
      prompt_id = tama_prompt.handle-marking.id
      layer     = 0
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

resource "tama_modular_thought" "forward-marking" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.handle-marking.id
  output_class_id = module.global.schemas.message-routing.id
  relation        = "routing"
  index           = 1

  module {
    reference = "tama/agentic/router"
    parameters = jsonencode({
      class_name = var.router_classification_class_name
      properties = var.router_classification_properties
      thread = {
        limit   = 7
        classes = module.memovee.thread_classes
        relations = {
          routing = "routing"
          focus   = ["tooling", "search-tooling", "reply"]
        }
      }
    })
  }
}

resource "tama_thought_processor" "marking-routing-processor" {
  thought_id = tama_modular_thought.forward-marking.id
  model_id   = module.openai.model_ids["gpt-5.1-mini-codex"]

  completion {
    temperature = 1.0
    parameters = jsonencode({
      reasoning = {
        effort = "low"
      }
    })
  }
}

resource "tama_prompt" "marking-routing" {
  space_id = tama_space.basic-conversation.id
  name     = "Marking Routing"
  role     = "system"
  content  = file("basic-marking/routing.md")
}

resource "tama_thought_context" "marking-routing-context" {
  thought_id = tama_modular_thought.forward-marking.id
  layer      = 0
  prompt_id  = tama_prompt.marking-routing.id
}

resource "tama_thought_path" "forward-marking-media-browsing" {
  depends_on = [tama_space_bridge.basic-conversation-media-conversation]

  thought_id      = tama_modular_thought.forward-marking.id
  target_class_id = module.movie-browsing-forwardable.class.id
}

resource "tama_thought_path" "forward-marking-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-marking.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "marking-artifact" {
  space_id = tama_space.basic-conversation.id
  name     = "Marking Artifact"
  role     = "system"
  content  = file("basic-marking/artifact.md")
}

resource "tama_thought_path_directive" "marking-artifact" {
  thought_path_id   = tama_thought_path.forward-marking-reply.id
  prompt_id         = tama_prompt.marking-artifact.id
  target_thought_id = tama_modular_thought.reply-artifact.id
}

resource "tama_prompt" "marking-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Marking Reply"
  role     = "system"
  content  = file("basic-marking/reply.md")
}

resource "tama_thought_path_directive" "marking-reply" {
  thought_path_id   = tama_thought_path.forward-marking-reply.id
  prompt_id         = tama_prompt.marking-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-marking" {
  space_id = tama_space.basic-conversation.id
  class_id = module.marking.class.id
  chain_id = tama_chain.handle-marking.id

  type = "reactive"
}

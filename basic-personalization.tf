resource "tama_chain" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Personalization"
}

resource "tama_prompt" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Personalization"
  role     = "system"
  content  = file("basic-personalization/tooling.md")
}

module "update-user-perference" {
  depends_on = [local.tool_call_class]

  source  = "upmaru/base/tama//modules/tooling"
  version = "0.4.6"

  chain_id = tama_chain.handle-personalization.id

  relation = "tooling"
  index    = 0

  tool_call_model_id          = module.openai.model_ids.gpt-5
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = {
    reasoning_effort = "minimal"
  }

  action_ids = [
    data.tama_action.get-user-preferences.id,
    data.tama_action.create-user-preference.id,
    data.tama_action.update-user-preference.id
  ]

  contexts = {
    upsert_profile = {
      prompt_id = tama_prompt.handle-personalization.id
      layer     = 0
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

resource "tama_modular_thought" "forward-personalization" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.handle-personalization.id
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

resource "tama_thought_processor" "personalization-routing-processor" {
  thought_id = tama_modular_thought.forward-personalization.id
  model_id   = module.openai.model_ids.gpt-5-mini

  completion {
    temperature = 1.0
    parameters = jsonencode({
      reasoning_effort = "minimal"
    })
  }
}

resource "tama_prompt" "personalization-routing" {
  space_id = tama_space.basic-conversation.id
  name     = "Personalization Routing"
  role     = "system"
  content  = file("basic-personalization/routing.md")
}

resource "tama_thought_context" "personalization-routing-context" {
  thought_id = tama_modular_thought.forward-personalization.id
  layer      = 0
  prompt_id  = tama_prompt.personalization-routing.id
}

resource "tama_thought_path" "forward-personalization-media-detail" {
  depends_on = [tama_space_bridge.basic-conversation-media-conversation]

  thought_id      = tama_modular_thought.forward-personalization.id
  target_class_id = module.movie-detail-forwardable.class.id
}

resource "tama_thought_path" "forward-personalization-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-personalization.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "personalization-artifact" {
  space_id = tama_space.basic-conversation.id
  name     = "Personalization Artifact"
  role     = "system"
  content  = file("basic-personalization/artifact.md")
}

resource "tama_thought_path_directive" "personalization-artifact" {
  thought_path_id   = tama_thought_path.forward-personalization-reply.id
  prompt_id         = tama_prompt.personalization-artifact.id
  target_thought_id = tama_modular_thought.reply-artifact.id
}

resource "tama_prompt" "personalization-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Personalization Reply"
  role     = "system"
  content  = file("basic-personalization/reply.md")
}

resource "tama_thought_path_directive" "personalization-reply" {
  thought_path_id   = tama_thought_path.forward-personalization-reply.id
  prompt_id         = tama_prompt.personalization-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  class_id = module.personalization.class.id
  chain_id = tama_chain.handle-personalization.id

  type = "reactive"
}

resource "tama_chain" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Personalization"
}

resource "tama_prompt" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Personalization"
  role     = "system"
  content = templatefile("basic-personalization/tooling.md", {
    get-user-preferences   = data.tama_action.get-user-preferences.identifier,
    create-user-preference = data.tama_action.create-user-preference.identifier
    update-user-preference = data.tama_action.update-user-preference.identifier
  })
}

module "update-user-perference" {
  source  = "upmaru/base/tama//modules/tooling"
  version = "0.3.16"

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

  chain_id = tama_chain.handle-personalization.id
  relation = "forwarding"
  index    = 1

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-personalization-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee-ui]

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
  class_id = tama_class.personalization.id
  chain_id = tama_chain.handle-personalization.id

  type = "reactive"
}

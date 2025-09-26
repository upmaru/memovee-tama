resource "tama_chain" "upsert-profile" {
  space_id = tama_space.basic-conversation.id
  name     = "Create or Update Profile"
}

resource "tama_prompt" "upsert-profile-tooling" {
  space_id = tama_space.basic-conversation.id
  name     = "Upsert Profile Tooling"
  role     = "system"
  content  = file("basic-upsert-profile/tooling.md")
}

module "upsert-profile-tooling" {
  source  = "upmaru/base/tama//modules/tooling"
  version = "0.3.16"

  chain_id = tama_chain.upsert-profile.id

  relation = "tooling"
  index    = 0

  tool_call_model_id          = module.openai.model_ids.gpt-5
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = {
    reasoning_effort = "minimal"
  }
  action_ids = [
    data.tama_action.update-user.id
  ]

  contexts = {
    upsert_profile = {
      prompt_id = tama_prompt.upsert-profile-tooling.id
      layer     = 0
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

resource "tama_modular_thought" "forward-upsert-profile" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.upsert-profile.id
  output_class_id = module.global.schemas.forwarding.id
  relation        = local.forwarding_relation
  index           = 1

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-upsert-profile" {
  depends_on = [
    tama_space_bridge.basic-conversation-prompt-assembly
  ]

  thought_id      = tama_modular_thought.forward-upsert-profile.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "upsert-profile-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Upsert Profile Reply"
  role     = "system"
  content  = file("basic-upsert-profile/reply.md")
}

resource "tama_thought_path_directive" "upsert-profile-reply" {
  thought_path_id   = tama_thought_path.forward-upsert-profile.id
  prompt_id         = tama_prompt.upsert-profile-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_prompt" "upsert-profile-artifact" {
  space_id = tama_space.basic-conversation.id
  name     = "Upsert Profile Artifact"
  role     = "system"
  content  = file("basic-upsert-profile/artifact.md")
}

resource "tama_thought_path_directive" "upsert-profile-artifact" {
  thought_path_id   = tama_thought_path.forward-upsert-profile.id
  prompt_id         = tama_prompt.upsert-profile-artifact.id
  target_thought_id = tama_modular_thought.reply-artifact.id
}

resource "tama_node" "handle-upsert-profile" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.introductory.id
  chain_id = tama_chain.upsert-profile.id

  type = "reactive"
}

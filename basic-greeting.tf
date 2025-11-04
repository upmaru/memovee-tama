resource "tama_chain" "load-profile-and-greet" {
  space_id = tama_space.basic-conversation.id
  name     = "Load Profile and Greet"
}

resource "tama_prompt" "check-profile-tooling" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Tooling"
  role     = "system"
  content  = file("basic-greeting/tooling.md")
}

module "check-profile-tooling" {
  depends_on = [local.tool_call_class]

  source  = "upmaru/base/tama//modules/tooling"
  version = "0.4.6"

  relation = "tooling"
  chain_id = tama_chain.load-profile-and-greet.id
  index    = 0

  tool_call_model_id          = module.openai.model_ids.gpt-5
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = {
    reasoning_effort = "minimal"
  }

  action_ids = [
    data.tama_action.get-user.id
  ]

  contexts = {
    check_profile = {
      prompt_id = tama_prompt.check-profile-tooling.id
      layer     = 0
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

resource "tama_modular_thought" "forward-check-profile" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.load-profile-and-greet.id
  output_class_id = module.global.schemas.forwarding.id
  relation        = local.forwarding_relation
  index           = 1

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "check-profile-reply" {
  thought_id      = tama_modular_thought.forward-check-profile.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "check-profile-artifact" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Artifact"
  role     = "system"
  content  = file("basic-greeting/artifact.md")
}

resource "tama_thought_path_directive" "check-profile-artifact" {
  thought_path_id   = tama_thought_path.check-profile-reply.id
  prompt_id         = tama_prompt.check-profile-artifact.id
  target_thought_id = tama_modular_thought.reply-artifact.id
}

resource "tama_prompt" "check-profile-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Reply"
  role     = "system"
  content  = file("basic-greeting/reply.md")
}

resource "tama_thought_path_directive" "check-profile-reply" {
  thought_path_id   = tama_thought_path.check-profile-reply.id
  prompt_id         = tama_prompt.check-profile-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-check-profile" {
  space_id = tama_space.basic-conversation.id
  class_id = module.greeting.class.id
  chain_id = tama_chain.load-profile-and-greet.id

  type = "reactive"
}

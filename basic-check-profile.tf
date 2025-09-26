resource "tama_chain" "load-profile-and-greet" {
  space_id = tama_space.basic-conversation.id
  name     = "Load Profile and Greet"
}

resource "tama_prompt" "check-profile-tooling" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Tooling"
  role     = "system"
  content  = file("basic-check-profile/tooling.md")
}

module "check-profile-tooling" {
  source  = "upmaru/base/tama//modules/tooling"
  version = "0.3.16"

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

  chain_id = tama_chain.load-profile-and-greet.id
  relation = "forward"
  index    = 1

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "check-profile-reply" {
  thought_id      = tama_modular_thought.forward-check-profile.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "check-profile-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Reply"
  role     = "system"
  content  = file("basic-check-profile/reply.md")
}

resource "tama_thought_path_directive" "check-profile-reply" {
  thought_path_id   = tama_thought_path.check-profile-reply.id
  prompt_id         = tama_prompt.check-profile-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-check-profile" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.greeting.id
  chain_id = tama_chain.load-profile-and-greet.id

  type = "reactive"
}

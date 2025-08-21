resource "tama_space" "basic-conversation" {
  name = "Basic Conversation"
  type = "component"
}

resource "tama_class" "off-topic" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("basic/off-topic.json")))
}

resource "tama_class" "greeting" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("basic/greeting.json")))
}

resource "tama_class" "introductory" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("basic/introductory.json")))
}

resource "tama_class" "curse" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("basic/curse.json")))
}

module "extract-embed-basic-conversation" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.2.39"

  depends_on = [module.global.schemas]

  name      = "Extract and Embed User Messages"
  space_id  = tama_space.basic-conversation.id
  relations = ["content"]


  embeddable_class_ids = [
    tama_class.greeting.id,
    tama_class.introductory.id
  ]
}

resource "tama_space_bridge" "basic-conversation-personalization" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.personalization.id
}

resource "tama_space_bridge" "basic-conversation-prompt-assembly" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.prompt-assembly.id
}

resource "tama_chain" "load-profile-and-greet" {
  space_id = tama_space.basic-conversation.id
  name     = "Load Profile and Greet"
}

resource "tama_prompt" "check-profile-tooling" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Tooling"
  role     = "system"
  content  = file("basic/check-profile/tooling.md")
}

resource "tama_prompt" "check-profile-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile Reply"
  role     = "system"
  content  = file("basic/check-profile/reply.md")
}

module "check-profile-tooling" {
  source  = "upmaru/base/tama//modules/tooling"
  version = "0.2.39"

  relation = "tooling"
  chain_id = tama_chain.load-profile-and-greet.id
  index    = 0

  assistant_response_class_id = local.assistant_response_class_id

  action_ids = [
    data.tama_action.get-profile.id
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

resource "tama_thought_path" "forward-as-context-component" {
  depends_on = [
    tama_space_bridge.basic-conversation-prompt-assembly
  ]

  thought_id      = tama_modular_thought.forward-check-profile.id
  target_class_id = tama_class.context-component.id
}

resource "tama_thought_context" "check-profile-reply" {
  thought_id = tama_modular_thought.forward-check-profile.id
  prompt_id  = tama_prompt.check-profile-reply.id
}

resource "tama_node" "handle-check-profile" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.greeting.id
  chain_id = tama_chain.load-profile-and-greet.id

  type = "reactive"
}

resource "tama_prompt" "upsert-profile-tooling" {
  space_id = tama_space.basic-conversation.id
  name     = "Upsert Profile Tooling"
  role     = "system"
  content  = file("basic/upsert-profile/tooling.md")
}

resource "tama_prompt" "upsert-profile-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Upsert Profile Reply"
  role     = "system"
  content  = file("basic/upsert-profile/reply.md")
}

resource "tama_chain" "upsert-profile" {
  space_id = tama_space.basic-conversation.id
  name     = "Create or Update Profile"
}

module "upsert-profile-tooling" {
  source  = "upmaru/base/tama//modules/tooling"
  version = "0.2.39"

  chain_id = tama_chain.upsert-profile.id

  relation                    = "tooling"
  index                       = 0
  assistant_response_class_id = local.assistant_response_class_id

  action_ids = [
    data.tama_action.upsert-profile.id
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

  chain_id = tama_chain.upsert-profile.id
  relation = "forwarding"
  index    = 1

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_context" "upsert-profile-reply" {
  thought_id = tama_modular_thought.forward-upsert-profile.id
  prompt_id  = tama_prompt.upsert-profile-reply.id
}

resource "tama_thought_path" "forward-upsert-profile" {
  depends_on = [
    tama_space_bridge.basic-conversation-prompt-assembly
  ]

  thought_id      = tama_modular_thought.forward-upsert-profile.id
  target_class_id = tama_class.context-component.id
}

resource "tama_node" "handle-upsert-profile" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.introductory.id
  chain_id = tama_chain.upsert-profile.id

  type = "reactive"
}

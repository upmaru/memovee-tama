resource "tama_space" "basic-conversation" {
  name = "Basic Conversation"
  type = "component"
}

resource "tama_class" "off-topic" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/off-topic.json")))
}

resource "tama_class" "greeting" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/greeting.json")))
}

resource "tama_class" "introductory" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/introductory.json")))
}

resource "tama_class" "curse" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/curse.json")))
}

module "extract-embed-basic-conversation" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.2.13"

  depends_on = [module.global.schemas]

  name     = "Extract and Embed User Messages"
  space_id = tama_space.basic-conversation.id
  relation = "content"

  answer_class_corpus_id = module.global.answer_corpus_id

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

resource "tama_prompt" "check-profile" {
  space_id = tama_space.basic-conversation.id
  name     = "Check Profile"
  role     = "system"
  content  = file("${path.module}/basic/check-profile.md")
}

resource "tama_prompt" "greeting-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Greeting Reply"
  role     = "system"
  content  = file("${path.module}/basic/greeting-reply.md")
}

locals {
  tool_calling_class_id = module.global.schemas["tool-calling"].id
  context_metadata_input = {
    type            = "metadata",
    class_corpus_id = module.global.context_metadata_corpus_id
  }
}

module "check-profile-tooling" {
  source  = "upmaru/base/tama//modules/tooling"
  version = "0.2.13"

  relation = "tooling"
  chain_id = tama_chain.load-profile-and-greet.id
  index    = 0

  tool_calling_class_id = local.tool_calling_class_id

  action_ids = [
    data.tama_action.get-profile.id
  ]

  contexts = {
    check_profile = {
      prompt_id = tama_prompt.check-profile.id
      layer     = 0
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

resource "tama_modular_thought" "forward-check-profile" {
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

resource "tama_thought_context" "greeting-reply" {
  thought_id = tama_modular_thought.forward-check-profile.id
  prompt_id  = tama_prompt.greeting-reply.id
}

resource "tama_node" "handle-greeting" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.greeting.id
  chain_id = tama_chain.load-profile-and-greet.id

  type = "reactive"
}

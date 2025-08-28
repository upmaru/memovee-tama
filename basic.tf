resource "tama_space" "basic-conversation" {
  name = "Basic Conversation"
  type = "component"
}

resource "tama_class" "off-topic" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/off-topic.json")))
}

resource "tama_class" "greeting" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/greeting.json")))
}

resource "tama_class" "introductory" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/introductory.json")))
}

resource "tama_class" "curse" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/curse.json")))
}

resource "tama_class" "manipulation" {
  space_id   = tama_space.basic-conversation.id
  depends_on = [module.global.schemas]
  schema {
    type  = "object"
    title = "manipulation"

    description = file("basic/manipulation.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

module "extract-embed-basic-conversation" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.3.6"

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
  version = "0.3.6"

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
  version = "0.3.6"

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

resource "tama_space_bridge" "basic-conversation-memovee" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = module.memovee.space.id
}

resource "tama_chain" "curse" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Cursing"
}

resource "tama_modular_thought" "forward-curse" {
  depends_on = [module.global.schemas]

  chain_id = tama_chain.curse.id
  relation = "forward"
  index    = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_prompt" "curse-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Curse Reply"
  role     = "system"
  content  = file("basic/curse/reply.md")
}

resource "tama_thought_context" "curse-reply" {
  thought_id = tama_modular_thought.forward-curse.id
  prompt_id  = tama_prompt.curse-reply.id
}

resource "tama_thought_path" "forward-curse-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-curse.id
  target_class_id = local.response_class_id
}

resource "tama_node" "handle-curse" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.curse.id
  chain_id = tama_chain.curse.id

  type = "reactive"
}

resource "tama_chain" "off-topic" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Off Topic Messages"
}

resource "tama_modular_thought" "forward-off-topic" {
  depends_on = [module.global.schemas]

  chain_id = tama_chain.off-topic.id
  relation = "forward"
  index    = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_prompt" "off-topic-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Off Topic Reply"
  role     = "system"
  content  = file("basic/off-topic/reply.md")
}

resource "tama_thought_context" "off-topic-reply" {
  thought_id = tama_modular_thought.forward-off-topic.id
  prompt_id  = tama_prompt.off-topic-reply.id
}

resource "tama_thought_path" "forward-off-topic-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-off-topic.id
  target_class_id = local.response_class_id
}

resource "tama_node" "handle-off-topic" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.off-topic.id
  chain_id = tama_chain.off-topic.id

  type = "reactive"
}

resource "tama_chain" "manipulation" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Manipulation"
}

resource "tama_modular_thought" "forward-manipulation" {
  depends_on = [module.global.schemas]

  chain_id = tama_chain.manipulation.id
  relation = "forward"
  index    = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_prompt" "manipulation-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Manipulation Reply"
  role     = "system"
  content  = file("basic/manipulation/reply.md")
}

resource "tama_thought_context" "manipulation-reply" {
  thought_id = tama_modular_thought.forward-manipulation.id
  prompt_id  = tama_prompt.manipulation-reply.id
}

resource "tama_thought_path" "forward-manipulation-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-manipulation.id
  target_class_id = local.response_class_id
}

resource "tama_node" "handle-manipulation" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.manipulation.id
  chain_id = tama_chain.manipulation.id

  type = "reactive"
}

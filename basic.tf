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

resource "tama_class" "personalization" {
  space_id   = tama_space.basic-conversation.id
  depends_on = [module.global.schemas]

  schema {
    type  = "object"
    title = "personalization"

    description = file("basic/personalization.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

resource "tama_class" "patch" {
  space_id   = tama_space.basic-conversation.id
  depends_on = [module.global.schemas]
  schema {
    type  = "object"
    title = "patch"

    description = file("basic/patch.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
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
  version = "0.3.16"

  depends_on = [module.global.schemas]

  name      = "Extract and Embed User Messages"
  space_id  = tama_space.basic-conversation.id
  relations = ["content"]


  embeddable_class_ids = [
    tama_class.greeting.id,
    tama_class.introductory.id
  ]
}

resource "tama_space_bridge" "basic-conversation-memovee-ui" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.ui.id
}

resource "tama_space_bridge" "basic-conversation-prompt-assembly" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.prompt-assembly.id
}

resource "tama_space_bridge" "basic-conversation-memovee" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = module.memovee.space.id
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

resource "tama_chain" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Personalization"
}

resource "tama_prompt" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Personalization"
  role     = "system"
  content = templatefile("basic/personalization/tooling.md", {
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

resource "tama_prompt" "personalization-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Personalization Reply"
  role     = "system"
  content  = file("basic/personalization/reply.md")
}

resource "tama_thought_context" "personalization-reply" {
  thought_id = tama_modular_thought.forward-personalization.id
  prompt_id  = tama_prompt.personalization-reply.id
}

resource "tama_thought_path" "forward-personalization-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee-ui]

  thought_id      = tama_modular_thought.forward-personalization.id
  target_class_id = local.response_class_id
}

resource "tama_node" "handle-personalization" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.personalization.id
  chain_id = tama_chain.handle-personalization.id

  type = "reactive"
}

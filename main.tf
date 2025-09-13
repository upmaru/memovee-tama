module "global" {
  source  = "upmaru/base/tama"
  version = "0.3.9"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.3.9"

  depends_on = [module.global.schemas]

  name                    = "memovee"
  entity_network_class_id = module.global.schemas["entity-network"].id
}


resource "tama_prompt" "memovee" {
  space_id = module.memovee.space.id

  name    = "Memovee Personality"
  role    = "system"
  content = file("memovee/persona.md")
}

resource "tama_space_bridge" "memovee-basic" {
  space_id        = module.memovee.space.id
  target_space_id = tama_space.basic-conversation.id
}

resource "tama_space_bridge" "memovee-media" {
  space_id        = module.memovee.space.id
  target_space_id = module.media-conversation.space_id
}

resource "tama_space_bridge" "memovee-ui" {
  space_id        = module.memovee.space.id
  target_space_id = tama_space.ui.id
}

resource "tama_prompt" "reply-template" {
  space_id = module.memovee.space.id

  name    = "Memovee Reply Template"
  role    = "system"
  content = file("memovee/reply.md")
}

resource "tama_chain" "reply-generation" {
  space_id = module.memovee.space.id
  name     = "Memovee Reply Generation"
}

//
// Create Artifact Tooling
//
resource "tama_modular_thought" "reply-artifact" {
  chain_id = tama_chain.reply-generation.id
  index    = 0
  relation = "create-artifact"

  depends_on = [
    module.global.schemas
  ]

  output_class_id = data.tama_class.tool-call.id

  module {
    reference = "tama/agentic/tooling"
    parameters = jsonencode({
      look_back_limit = 3
    })
  }
}

resource "tama_prompt" "reply-artifact" {
  space_id = module.memovee.space.id

  name    = "Memovee Reply Artifact"
  role    = "system"
  content = file("memovee-ui/artifact.md")
}

module "artifact-context" {
  source  = "upmaru/base/tama//modules/thought-context"
  version = "0.3.9"

  thought_id = tama_modular_thought.reply-artifact.id
  contexts = {
    artifact = {
      prompt_id = tama_prompt.reply-artifact.id
      layer     = 0
    }

    reply = {
      prompt_id = tama_prompt.reply-template.id
      layer     = 1
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

data "tama_action" "create-artifact" {
  specification_id = tama_specification.ui.id
  method           = "POST"
  path             = "/conversation/messages/{message_id}/artifacts"
}

resource "tama_thought_tool" "create-artifact-tool" {
  thought_id = tama_modular_thought.reply-artifact.id
  action_id  = data.tama_action.create-artifact.id
}

resource "tama_thought_processor" "artifact-processor" {
  thought_id = tama_modular_thought.reply-artifact.id
  model_id   = module.openai.model_ids.gpt-5-mini

  completion {
    temperature = 1.0
    parameters = jsonencode({
      reasoning_effort = "low"
    })
  }
}

//
// Text reply generation
//
resource "tama_modular_thought" "reply-generation" {
  chain_id = tama_chain.reply-generation.id
  index    = 1
  relation = "reply"

  output_class_id = local.assistant_response_class_id

  module {
    reference = "tama/agentic/reply"
    parameters = jsonencode({
      look_back_limit = 3
    })
  }
}

locals {
  assistant_response_class_id = module.global.schemas["assistant-response"].id
  response_class_id           = module.memovee.schemas["response"].id

  context_metadata_input = {
    type            = "metadata",
    class_corpus_id = module.global.context_metadata_corpus_id
  }
}

resource "tama_thought_processor" "reply-processor" {
  thought_id = tama_modular_thought.reply-generation.id
  model_id   = module.openai.model_ids.gpt-5-mini

  completion {
    temperature = 1.0
    parameters = jsonencode({
      reasoning_effort = "low"
    })
  }
}

module "reply-context" {
  source  = "upmaru/base/tama//modules/thought-context"
  version = "0.3.9"

  thought_id = tama_modular_thought.reply-generation.id
  contexts = {
    persona = {
      prompt_id = tama_prompt.memovee.id
      layer     = 0
    }

    reply = {
      prompt_id = tama_prompt.reply-template.id
      layer     = 1
      inputs = [
        local.context_metadata_input
      ]
    }
  }
}

resource "tama_node" "handle-reply-generation" {
  space_id = module.memovee.space.id
  class_id = local.response_class_id
  chain_id = tama_chain.reply-generation.id

  type = "reactive"
}

resource "tama_listener" "memovee-ui-listener" {
  space_id = module.memovee.space.id
  endpoint = "http://localhost:4001/tama/broadcasts"
}

resource "tama_listener_topic" "user-message-topic" {
  listener_id = tama_listener.memovee-ui-listener.id
  class_id    = module.memovee.schemas.user-message.id
}

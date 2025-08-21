module "global" {
  source  = "upmaru/base/tama"
  version = "0.2.39"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.2.39"

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

resource "tama_modular_thought" "reply-generation" {
  chain_id = tama_chain.reply-generation.id
  index    = 0
  relation = "reply"

  output_class_id = local.assistant_response_class_id

  module {
    reference = "tama/agentic/reply"
  }
}

locals {
  assistant_response_class_id = module.global.schemas["assistant-response"].id
  reply_model_id              = module.mistral.model_ids["mistral-small-latest"]
  response_class_id           = module.memovee.schemas["response"].id

  context_metadata_input = {
    type            = "metadata",
    class_corpus_id = module.global.context_metadata_corpus_id
  }
}

resource "tama_thought_processor" "reply-processor" {
  thought_id = tama_modular_thought.reply-generation.id
  model_id   = local.reply_model_id

  completion_config {
    temperature = 0.0
  }
}

module "reply-context" {
  source  = "upmaru/base/tama//modules/thought-context"
  version = "0.2.39"

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

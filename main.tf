module "global" {
  source  = "upmaru/base/tama"
  version = "0.4.1"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.4.1"

  depends_on = [module.global.schemas]

  name = "memovee"
}

resource "tama_prompt" "memovee" {
  space_id = module.memovee.space_id

  name    = "Memovee Personality"
  role    = "system"
  content = file("memovee/persona.md")
}

resource "tama_space_bridge" "memovee-basic" {
  space_id        = module.memovee.space_id
  target_space_id = tama_space.basic-conversation.id
}

resource "tama_space_bridge" "memovee-media" {
  space_id        = module.memovee.space_id
  target_space_id = tama_space.media-conversation.id
}

resource "tama_space_bridge" "memovee-ui" {
  space_id        = module.memovee.space_id
  target_space_id = tama_space.ui.id
}

resource "tama_prompt" "reply-template" {
  space_id = module.memovee.space_id

  name    = "Memovee Reply Template"
  role    = "system"
  content = file("memovee/reply.md")
}

resource "tama_chain" "reply-generation" {
  space_id = module.memovee.space_id
  name     = "Memovee Reply Generation"
}

locals {
  create_artifact_relation = "create-artifact"
  reply_relation           = "reply"
  forwarding_relation      = "forwarding"
}

//
// Create Artifact Tooling
//
resource "tama_modular_thought" "reply-artifact" {
  chain_id = tama_chain.reply-generation.id
  index    = 0
  relation = local.create_artifact_relation

  depends_on = [
    module.global.schemas
  ]

  output_class_id = data.tama_class.tool-call.id

  module {
    reference = "tama/agentic/tooling"
    parameters = jsonencode({
      thread = {
        limit = 1
        classes = {
          author  = module.memovee.schemas.actor.name
          thread  = module.memovee.schemas.thread.name
          message = module.memovee.schemas.user-message.name
        }
        relations = {
          routing = module.router.routing_thought_relation
          focus = [
            "tooling",
            "search-tooling",
            local.reply_relation
          ]
        }
      }
    })
  }
}

resource "tama_prompt" "reply-artifact" {
  space_id = module.memovee.space_id

  name    = "Memovee Reply Artifact"
  role    = "system"
  content = file("interface/artifact.md")
}

module "artifact-context" {
  source  = "upmaru/base/tama//modules/thought-context"
  version = "0.4.1"

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
  relation = local.reply_relation

  output_class_id = local.assistant_response_class_id

  module {
    reference = "tama/agentic/reply"
    parameters = jsonencode({
      thread = {
        limit = 1
        classes = {
          author  = module.memovee.schemas.actor.name
          thread  = module.memovee.schemas.thread.name
          message = module.memovee.schemas.user-message.name
        }
        relations = {
          routing = module.router.routing_thought_relation
          focus = [
            "tooling",
            "search-tooling",
            local.create_artifact_relation,
            local.reply_relation
          ]
        }
      }
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
  version = "0.4.1"

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
  space_id = module.memovee.space_id
  class_id = local.response_class_id
  chain_id = tama_chain.reply-generation.id

  type = "reactive"
}

variable "memovee_listener_secret" {
  type        = string
  description = "The secret for the Memovee UI listener"
}

resource "tama_listener" "memovee-ui-listener" {
  space_id = module.memovee.space_id
  endpoint = "http://localhost:4001/tama/hook/broadcasts"
  secret   = var.memovee_listener_secret
}

resource "tama_listener_topic" "user-message-topic" {
  listener_id = tama_listener.memovee-ui-listener.id
  class_id    = module.memovee.schemas.user-message.id
}

//
// Listener Filters
//
resource "tama_listener_filter" "reply-generation" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.reply-generation.id
}

resource "tama_listener_filter" "load-profile-and-greet" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.load-profile-and-greet.id
}

resource "tama_listener_filter" "upsert-profile" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.upsert-profile.id
}

resource "tama_listener_filter" "curse" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.curse.id
}

resource "tama_listener_filter" "off-topic" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.off-topic.id
}

resource "tama_listener_filter" "manipulation" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.manipulation.id
}

resource "tama_listener_filter" "patch-reply" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.patch-reply.id
}

resource "tama_listener_filter" "personalization" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.handle-personalization.id
}

resource "tama_listener_filter" "media-browsing" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = module.media-browsing.chain_id
}

resource "tama_listener_filter" "media-detail" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = module.media-detail.chain_id
}

resource "tama_listener_filter" "person-browsing" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = module.person-browsing.chain_id
}

resource "tama_listener_filter" "person-detail" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = module.person-detail.chain_id
}

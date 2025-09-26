resource "tama_chain" "off-topic" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Off Topic Messages"
}

resource "tama_modular_thought" "forward-off-topic" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.off-topic.id
  output_class_id = module.global.schemas.forwarding.id
  relation        = local.forwarding_relation
  index           = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-off-topic-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-off-topic.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "off-topic-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Off Topic Reply"
  role     = "system"
  content  = file("basic-off-topic/reply.md")
}

resource "tama_thought_path_directive" "off-topic-reply" {
  thought_path_id   = tama_thought_path.forward-off-topic-reply.id
  prompt_id         = tama_prompt.off-topic-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-off-topic" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.off-topic.id
  chain_id = tama_chain.off-topic.id

  type = "reactive"
}

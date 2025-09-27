resource "tama_chain" "manipulation" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Manipulation"
}

resource "tama_modular_thought" "forward-manipulation" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.manipulation.id
  output_class_id = module.global.schemas.forwarding.id
  relation        = local.forwarding_relation
  index           = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-manipulation-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-manipulation.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "manipulation-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Manipulation Reply"
  role     = "system"
  content  = file("basic-manipulation/reply.md")
}

resource "tama_thought_path_directive" "manipulation-reply" {
  thought_path_id   = tama_thought_path.forward-manipulation-reply.id
  prompt_id         = tama_prompt.manipulation-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-manipulation" {
  space_id = tama_space.basic-conversation.id
  class_id = module.manipulation.class.id
  chain_id = tama_chain.manipulation.id

  type = "reactive"
}

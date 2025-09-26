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

resource "tama_thought_path" "forward-curse-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-curse.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "curse-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Curse Reply"
  role     = "system"
  content  = file("basic-curse/reply.md")
}

resource "tama_thought_path_directive" "curse-reply" {
  thought_path_id   = tama_thought_path.forward-curse-reply.id
  prompt_id         = tama_prompt.curse-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-curse" {
  space_id = tama_space.basic-conversation.id
  class_id = tama_class.curse.id
  chain_id = tama_chain.curse.id

  type = "reactive"
}

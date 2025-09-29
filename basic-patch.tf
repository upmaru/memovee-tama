resource "tama_chain" "patch-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Patching"
}

resource "tama_modular_thought" "forward-patch" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.patch-reply.id
  output_class_id = module.global.schemas.forwarding.id
  relation        = local.forwarding_relation
  index           = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-patch-reply" {
  depends_on = [tama_space_bridge.basic-conversation-memovee]

  thought_id      = tama_modular_thought.forward-patch.id
  target_class_id = local.response_class_id
}

resource "tama_prompt" "patch-artifact" {
  space_id = tama_space.basic-conversation.id
  name     = "Patch Artifact"
  role     = "system"
  content  = file("basic-patch/artifact.md")
}

resource "tama_thought_path_directive" "forward-patch-artifact" {
  thought_path_id   = tama_thought_path.forward-patch-reply.id
  prompt_id         = tama_prompt.patch-artifact.id
  target_thought_id = tama_modular_thought.reply-artifact.id
}

resource "tama_prompt" "patch-reply" {
  space_id = tama_space.basic-conversation.id
  name     = "Patch Reply"
  role     = "system"
  content  = file("basic-patch/reply.md")
}

resource "tama_thought_path_directive" "forward-patch-reply" {
  thought_path_id   = tama_thought_path.forward-patch-reply.id
  prompt_id         = tama_prompt.patch-reply.id
  target_thought_id = tama_modular_thought.reply-generation.id
}

resource "tama_node" "handle-patch" {
  space_id = tama_space.basic-conversation.id
  class_id = module.patch.class.id
  chain_id = tama_chain.patch-reply.id

  type = "reactive"
}

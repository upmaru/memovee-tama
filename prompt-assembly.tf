resource "tama_space" "prompt-assembly" {
  name = "Prompt Assembly"
  type = "component"
}

resource "tama_class" "context-component" {
  space_id = tama_space.prompt-assembly.id

  depends_on = [module.global]

  schema_json = jsonencode(
    jsondecode(file("prompt-assembly/context-component.json"))
  )
}

resource "tama_space_bridge" "prompt-assembly-memovee" {
  space_id        = tama_space.prompt-assembly.id
  target_space_id = module.memovee.space.id
}

resource "tama_chain" "reply-context-assembly" {
  space_id = tama_space.prompt-assembly.id
  name     = "Reply Context Assembly"
}

resource "tama_modular_thought" "context-merge" {
  depends_on = [module.global.schemas]

  chain_id = tama_chain.reply-context-assembly.id
  index    = 0
  relation = "merge"

  module {
    reference = "tama/contexts/merge"
  }
}

resource "tama_modular_thought" "forward-to-reply" {
  depends_on = [module.global.schemas]

  chain_id = tama_chain.reply-context-assembly.id
  index    = 1
  relation = "forward"

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-to-reply" {
  thought_id      = tama_modular_thought.forward-to-reply.id
  target_class_id = local.response_class_id
}

resource "tama_node" "handle-context-assembly" {
  space_id = tama_space.prompt-assembly.id
  class_id = tama_class.context-component.id
  chain_id = tama_chain.reply-context-assembly.id

  type = "reactive"
}

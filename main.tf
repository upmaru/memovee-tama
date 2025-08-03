module "global" {
  source  = "upmaru/base/tama"
  version = "0.2.8"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.2.8"

  depends_on = [module.global.schemas]

  name = "memovee"
}

resource "tama_prompt" "memovee" {
  space_id = module.memovee.space.id

  name    = "Memovee Personality"
  role    = "system"
  content = file("${path.module}/memovee/persona.md")
}

resource "tama_space_bridge" "memovee-basic" {
  space_id        = module.memovee.space.id
  target_space_id = tama_space.basic-conversation.id
}

resource "tama_space_bridge" "memovee-media" {
  space_id        = module.memovee.space.id
  target_space_id = tama_space.media-conversation.id
}

resource "tama_chain" "network-message" {
  space_id = module.memovee.space.id
  name     = "Network Message"
}

resource "tama_delegated_thought" "network-message" {
  chain_id = tama_chain.network-message.id

  delegation {
    target_thought_id = module.router.network_thought_id
  }
}

resource "tama_node" "network-assistant-message" {
  space_id = module.memovee.space.id
  class_id = module.memovee.schemas["assistant-message"].id
  chain_id = tama_chain.network-message.id

  type = "reactive"
}

resource "tama_node" "network-tool-message" {
  space_id = module.memovee.space.id
  class_id = module.memovee.schemas["tool-message"].id
  chain_id = tama_chain.network-message.id

  type = "reactive"
}

module "global" {
  source  = "upmaru/base/tama"
  version = "0.2.12"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.2.12"

  depends_on = [module.global.schemas]

  name                    = "memovee"
  entity_network_class_id = module.global.schemas["entity-network"].id
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

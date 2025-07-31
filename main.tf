module "global" {
  source  = "upmaru/base/tama"
  version = "0.2.2"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.2.2"

  name                 = "memovee"
  class_proxy_class_id = module.global.schemas["class-proxy"].id
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

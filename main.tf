module "global" {
  source  = "upmaru/base/tama"
  version = "0.2.7"
}

module "memovee" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.2.7"

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

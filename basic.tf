resource "tama_space" "basic-conversation" {
  name = "Basic Conversation"
  type = "component"
}

module "off-topic" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "off-topic"
  description = file("basic/off-topic.md")
}

module "greeting" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "greeting"
  description = file("basic/greeting.md")
}


module "introductory" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "introductory"
  description = file("basic/introductory.md")
}

module "curse" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "curse"
  description = file("basic/curse.md")
}

module "personalization" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "personalization"
  description = file("basic/personalization.md")
}

module "patch" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "patch"
  description = file("basic/patch.md")
}

module "manipulation" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "manipulation"
  description = file("basic/manipulation.md")
}

module "marking" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.3"
  depends_on = [module.global.schemas]

  space_id    = tama_space.basic-conversation.id
  title       = "marking"
  description = file("basic/marking.md")
}

resource "tama_space_bridge" "basic-conversation-memovee-ui" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.ui.id
}

resource "tama_space_bridge" "basic-conversation-memovee" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = module.memovee.space_id
}

resource "tama_space_bridge" "basic-conversation-media-conversation" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.media-conversation.id
}

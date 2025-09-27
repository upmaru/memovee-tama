resource "tama_space" "media-conversation" {
  name = "Media Conversation"
  type = "component"
}

module "media-detail-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.0"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "media-detail"
  description = file("media/media-detail.md")
}

module "media-browsing-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.0"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "media-browsing"
  description = file("media/media-browsing.md")
}

module "person-detail-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.0"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "person-detail"
  description = file("media/media-person-detail.md")
}

module "person-browsing-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.4.0"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "person-browsing"
  description = file("media/media-person-browsing.md")
}

resource "tama_space_bridge" "media-conversation-to-movie-db" {
  space_id        = tama_space.media-conversation.id
  target_space_id = module.movie-db.space_id
}

resource "tama_space_bridge" "media-conversation-to-memovee-ui" {
  space_id        = tama_space.media-conversation.id
  target_space_id = tama_space.ui.id
}

resource "tama_space_bridge" "media-conversation-to-memovee" {
  space_id        = tama_space.media-conversation.id
  target_space_id = module.memovee.space_id
}

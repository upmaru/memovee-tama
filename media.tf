resource "tama_space" "media-conversation" {
  name = "Media Conversation"
  type = "component"
}

module "movie-detail-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "movie-detail"
  description = file("media/movie-detail.md")
}

module "movie-browsing-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "movie-browsing"
  description = file("media/movie-browsing.md")
}

module "movie-by-person-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "movie-by-person"
  description = file("media/movie-by-person.md")
}

module "movie-analytics-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "movie-analytics"
  description = file("media/movie-analytics.md")
}

module "person-detail-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "person-detail"
  description = file("media/person-detail.md")
}

module "person-browsing-forwardable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-conversation.id
  title       = "person-browsing"
  description = file("media/person-browsing.md")
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

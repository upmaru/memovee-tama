resource "tama_space" "media-conversation" {
  name = "Media Conversation"
  type = "component"
}

resource "tama_class" "media-detail" {
  space_id   = tama_space.media-conversation.id
  depends_on = [module.global]

  schema {
    type  = "object"
    title = "media-detail"

    description = file("${path.module}/media/media-detail.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

resource "tama_class" "media-browsing" {
  space_id   = tama_space.media-conversation.id
  depends_on = [module.global]

  schema {
    type  = "object"
    title = "media-browsing"

    description = file("${path.module}/media/media-browsing.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

resource "tama_class" "person-detail" {
  space_id   = tama_space.media-conversation.id
  depends_on = [module.global]

  schema {
    type  = "object"
    title = "person-detail"

    description = file("${path.module}/media/person-detail.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

resource "tama_class" "person-browsing" {
  space_id   = tama_space.media-conversation.id
  depends_on = [module.global]

  schema {
    type  = "object"
    title = "person-browsing"

    description = file("${path.module}/media/person-browsing.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

module "extract-embed-media-conversation" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.2.19"

  depends_on = [module.global.schemas]

  name     = "Extract and Embed Media Conversation"
  space_id = tama_space.media-conversation.id

  answer_class_corpus_id = module.global.answer_corpus_id

  embeddable_class_ids = [
    tama_class.person-detail.id,
    tama_class.person-browsing.id,
    tama_class.media-detail.id,
    tama_class.media-browsing.id
  ]
}

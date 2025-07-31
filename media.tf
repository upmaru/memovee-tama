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

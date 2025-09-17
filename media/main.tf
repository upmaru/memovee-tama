resource "tama_space" "this" {
  name = "Media Conversation"
  type = "component"
}

resource "tama_class" "media-detail" {
  space_id = tama_space.this.id

  schema {
    type  = "object"
    title = "media-detail"

    description = file("${path.module}/media-detail.md")

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
  space_id = tama_space.this.id

  schema {
    type  = "object"
    title = "media-browsing"

    description = file("${path.module}/media-browsing.md")

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
  space_id = tama_space.this.id

  schema {
    type  = "object"
    title = "person-detail"

    description = file("${path.module}/person-detail.md")

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
  space_id = tama_space.this.id

  schema {
    type  = "object"
    title = "person-browsing"

    description = file("${path.module}/person-browsing.md")

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
  version = "0.3.15"

  name      = "Extract and Embed Media Conversation"
  space_id  = tama_space.this.id
  relations = ["content"]

  embeddable_class_ids = [
    tama_class.person-detail.id,
    tama_class.person-browsing.id,
    tama_class.media-detail.id,
    tama_class.media-browsing.id
  ]
}

resource "tama_space_bridge" "media-conversation-to-movie-db" {
  space_id        = tama_space.this.id
  target_space_id = var.movie_db_space_id
}

resource "tama_space_bridge" "media-conversation-to-prompt-assembly" {
  space_id        = tama_space.this.id
  target_space_id = var.prompt_assembly_space_id
}

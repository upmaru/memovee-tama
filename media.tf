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

    description = file("media/media-detail.md")

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

    description = file("media/media-browsing.md")

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

    description = file("media/person-detail.md")

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

    description = file("media/person-browsing.md")

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
  version = "0.2.37"

  depends_on = [module.global.schemas]

  name      = "Extract and Embed Media Conversation"
  space_id  = tama_space.media-conversation.id
  relations = ["content"]

  embeddable_class_ids = [
    tama_class.person-detail.id,
    tama_class.person-browsing.id,
    tama_class.media-detail.id,
    tama_class.media-browsing.id
  ]
}

resource "tama_space_bridge" "media-conversation-to-movie-db" {
  space_id        = tama_space.media-conversation.id
  target_space_id = module.movie-db.space_id
}

resource "tama_space_bridge" "media-conversation-to-prompt-assembly" {
  space_id        = tama_space.media-conversation.id
  target_space_id = tama_space.prompt-assembly.id
}

module "media-browsing" {
  source = "./media-browse"

  depends_on = [module.global, module.movie-db]

  media_conversation_space_id = tama_space.media-conversation.id
  tool_call_model_id          = module.mistral.model_ids["mistral-medium-latest"]

  prompt_assembly_space_id = tama_space.prompt-assembly.id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.movie_db_index_definition_relation
}

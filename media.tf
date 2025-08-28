module "media-conversation" {
  source = "./media"

  depends_on = [module.global.schemas]

  movie_db_space_id        = module.movie-db.space_id
  prompt_assembly_space_id = tama_space.prompt-assembly.id
}


resource "tama_prompt" "media-browsing-tooling" {
  space_id = module.media-conversation.space_id
  name     = "Media Browsing Tooling"
  role     = "system"
  content  = file("${path.module}/media-browsing/querying.md")
}

resource "tama_prompt" "media-browsing-reply" {
  space_id = module.media-conversation.space_id
  name     = "Media Browsing Reply"
  role     = "system"
  content  = file("${path.module}/media-browsing/reply.md")
}

module "media-browsing" {
  source = "./media-conversate"

  depends_on = [module.global, module.index-definition-generation]

  name                        = "Media Browsing"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["media-browsing"]

  tool_call_model_id          = module.openai.model_ids.gpt-5-mini
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id = tama_prompt.media-browsing-tooling.id
  reply_prompt_id   = tama_prompt.media-browsing-reply.id

  prompt_assembly_space_id = tama_space.prompt-assembly.id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index
}

resource "tama_prompt" "media-detail-tooling" {
  space_id = module.media-conversation.space_id
  name     = "Media Detail Tooling"
  role     = "system"
  content  = file("${path.module}/media-detail/querying.md")
}

resource "tama_prompt" "media-detail-reply" {
  space_id = module.media-conversation.space_id
  name     = "Media Detail Reply"
  role     = "system"
  content  = file("${path.module}/media-detail/reply.md")
}

module "media-detail" {
  source = "./media-conversate"

  depends_on = [
    module.global,
    module.index-definition-generation
  ]

  name                        = "Media Detail"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["media-detail"]

  tool_call_model_id          = module.openai.model_ids.gpt-5-mini
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id = tama_prompt.media-detail-tooling.id
  reply_prompt_id   = tama_prompt.media-detail-reply.id

  prompt_assembly_space_id = tama_space.prompt-assembly.id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index
}

resource "tama_prompt" "person-browse-tooling" {
  space_id = module.media-conversation.space_id
  name     = "Person Browse Tooling"
  role     = "system"
  content  = file("${path.module}/person-browse/querying.md")
}

resource "tama_prompt" "person-browse-reply" {
  space_id = module.media-conversation.space_id
  name     = "Person Browse Reply"
  role     = "system"
  content  = file("${path.module}/person-browse/reply.md")
}

module "person-browsing" {
  source = "./media-conversate"

  depends_on = [
    module.global,
    module.index-definition-generation
  ]

  name                        = "Person Browsing"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["person-browsing"]

  tool_call_model_id          = module.openai.model_ids.gpt-5-mini
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })
  tooling_prompt_id = tama_prompt.person-browse-tooling.id
  reply_prompt_id   = tama_prompt.person-browse-reply.id

  prompt_assembly_space_id = tama_space.prompt-assembly.id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.person-index
}

resource "tama_prompt" "person-detail-tooling" {
  space_id = module.media-conversation.space_id
  name     = "Person Detail Tooling"
  role     = "system"
  content  = file("${path.module}/person-detail/querying.md")
}

resource "tama_prompt" "person-detail-reply" {
  space_id = module.media-conversation.space_id
  name     = "Person Detail Reply"
  role     = "system"
  content  = file("${path.module}/person-detail/reply.md")
}

module "person-detail" {
  source = "./media-conversate"

  depends_on = [
    module.global,
    module.index-definition-generation
  ]

  name                        = "Person Detail"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["person-detail"]

  tool_call_model_id          = module.openai.model_ids.gpt-5-mini
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id = tama_prompt.person-detail-tooling.id
  reply_prompt_id   = tama_prompt.person-detail-reply.id

  prompt_assembly_space_id = tama_space.prompt-assembly.id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.person-index
}

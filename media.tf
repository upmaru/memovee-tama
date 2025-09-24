module "media-conversation" {
  source = "./media"

  depends_on = [module.global.schemas]

  movie_db_space_id        = module.movie-db.space_id
  prompt_assembly_space_id = tama_space.prompt-assembly.id
  memovee_ui_space_id      = tama_space.ui.id
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

//
// Media Browsing
//
module "media-browsing" {
  source = "./media-conversate"

  depends_on = [
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Media Browsing"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["media-browsing"]

  author_class_name  = module.memovee.schemas.actor.name
  thread_class_name  = module.memovee.schemas.thread.name
  message_class_name = module.memovee.schemas.user-message.name

  routing_thought_relation = module.router.routing_thought_relation

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




//
// Media Detail
//
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
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Media Detail"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["media-detail"]

  author_class_name  = module.memovee.schemas.actor.name
  thread_class_name  = module.memovee.schemas.thread.name
  message_class_name = module.memovee.schemas.user-message.name

  routing_thought_relation = module.router.routing_thought_relation

  tool_call_model_id          = module.openai.model_ids.gpt-5
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

module "watch-providers" {
  source = "./watch-providers"

  tmdb_specification_id = module.movie-db.tmdb_specification_id
}

//
// Watch Providers Tooling
//
resource "tama_thought_tool" "watch-providers" {
  thought_id = module.media-detail.tooling_thought_id
  action_id  = module.watch-providers.action_id
}

resource "tama_thought_tool_output" "watch-providers-output" {
  thought_tool_id = tama_thought_tool.watch-providers.id
  class_corpus_id = module.watch-providers.class_corpus_id
}

resource "tama_tool_output_option" "watch-providers-region" {
  thought_tool_output_id = tama_thought_tool_output.watch-providers-output.id
  action_modifier_id     = module.watch-providers.action_modifier_id
}

//
// Check User Preferences Tooling
//
resource "tama_thought_tool" "media-detail-check-user-preferences" {
  depends_on = [module.media-conversation]

  thought_id = module.media-detail.tooling_thought_id
  action_id  = data.tama_action.get-user-preferences.id
}


//
// Person Browsing
//
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

  author_class_name  = module.memovee.schemas.actor.name
  thread_class_name  = module.memovee.schemas.thread.name
  message_class_name = module.memovee.schemas.user-message.name

  routing_thought_relation = module.router.routing_thought_relation

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

  author_class_name  = module.memovee.schemas.actor.name
  thread_class_name  = module.memovee.schemas.thread.name
  message_class_name = module.memovee.schemas.user-message.name

  routing_thought_relation = module.router.routing_thought_relation

  tool_call_model_id          = module.openai.model_ids.gpt-5
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

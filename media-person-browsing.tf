//
// Person Browsing
//
resource "tama_prompt" "person-browse-tooling" {
  space_id = module.media-conversation.space_id
  name     = "Person Browse Tooling"
  role     = "system"
  content  = file("media-person-browse/querying.md")
}

resource "tama_prompt" "person-browse-reply" {
  space_id = module.media-conversation.space_id
  name     = "Person Browse Reply"
  role     = "system"
  content  = file("media-person-browse/reply.md")
}

module "person-browsing" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global,
    module.media-conversation,
    module.index-definition-generation
  ]

  name                        = "Person Browsing"
  media_conversation_space_id = module.media-conversation.space_id
  target_class_id             = module.media-conversation.class_ids["person-browsing"]

  author_class_name  = module.memovee.schemas.actor.name
  thread_class_name  = module.memovee.schemas.thread.name
  message_class_name = module.memovee.schemas.user-message.name

  routing_thought_relation = module.router.routing_thought_relation
  forwarding_relation      = local.forwarding_relation

  tool_call_model_id          = module.openai.model_ids.gpt-5-mini
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id           = tama_prompt.person-browse-tooling.id
  reply_prompt_id             = tama_prompt.person-browse-reply.id
  reply_artifact_thought_id   = tama_modular_thought.reply-artifact.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.person-index
}

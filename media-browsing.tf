resource "tama_prompt" "media-browsing-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Media Browsing Tooling"
  role     = "system"
  content  = file("media-browsing/querying.md")
}

resource "tama_prompt" "media-browsing-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Media Browsing Reply"
  role     = "system"
  content  = file("media-browsing/reply.md")
}

resource "tama_prompt" "media-browsing-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Media Browsing Artifact"
  role     = "system"
  content  = file("media-browsing/artifact.md")
}

//
// Media Browsing
//
module "media-browsing" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Media Browsing"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.media-browsing-forwardable.class.id

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

  tooling_prompt_id = tama_prompt.media-browsing-tooling.id

  reply_prompt_id             = tama_prompt.media-browsing-reply.id
  reply_artifact_prompt_id    = tama_prompt.media-browsing-artifact.id
  reply_artifact_thought_id   = tama_modular_thought.reply-artifact.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index
}

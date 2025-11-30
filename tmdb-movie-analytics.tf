resource "tama_prompt" "movie-analytics-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Movie Analytics Tooling"
  role     = "system"
  content  = file("tmdb-movie-analytics/querying.md")
}

resource "tama_prompt" "movie-analytics-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Movie Analytics Reply"
  role     = "system"
  content  = file("tmdb-movie-analytics/reply.md")
}

resource "tama_prompt" "movie-analytics-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Movie Analytics Artifact"
  role     = "system"
  content  = file("tmdb-movie-analytics/artifact.md")
}

module "movie-analytics" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Movie Analytics"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.movie-analytics-forwardable.class.id

  thread_classes = module.memovee.thread_classes

  routing_thought_relation = module.router.routing_thought_relation
  forwarding_relation      = local.forwarding_relation

  tool_call_model_id          = module.openai.model_ids.gpt-5-mini
  tool_call_tool_choice       = "required"
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id = tama_prompt.movie-analytics-tooling.id

  reply_prompt_id             = tama_prompt.movie-analytics-reply.id
  reply_artifact_prompt_id    = tama_prompt.movie-analytics-artifact.id
  reply_artifact_thought_id   = tama_modular_thought.reply-artifact.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index
}

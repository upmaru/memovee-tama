resource "tama_prompt" "movie-browsing-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Movie Browsing Tooling"
  role     = "system"
  content  = file("tmdb-movie-browsing/querying.md")
}

resource "tama_prompt" "movie-browsing-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Movie Browsing Reply"
  role     = "system"
  content  = file("tmdb-movie-browsing/reply.md")
}

resource "tama_prompt" "movie-browsing-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Movie Browsing Artifact"
  role     = "system"
  content  = file("tmdb-movie-browsing/artifact.md")
}

module "movie-browsing" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Movie Browsing"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.movie-browsing-forwardable.class.id

  thread_classes = module.memovee.thread_classes

  routing_thought_relation = module.router.routing_thought_relation
  forwarding_relation      = local.forwarding_relation

  tool_call_model_id          = module.openai.model_ids["gpt-5-mini"]
  tool_call_tool_choice       = "required"
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id = tama_prompt.movie-browsing-tooling.id

  reply_prompt_id             = tama_prompt.movie-browsing-reply.id
  reply_artifact_prompt_id    = tama_prompt.movie-browsing-artifact.id
  reply_artifact_thought_id   = tama_modular_thought.reply-artifact.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index
}

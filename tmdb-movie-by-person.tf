resource "tama_prompt" "movie-by-person-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Movie By Person Tooling"
  role     = "system"
  content  = file("tmdb-movie-by-person/querying.md")
}

resource "tama_prompt" "movie-by-person-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Movie By Person Reply"
  role     = "system"
  content  = file("tmdb-movie-by-person/reply.md")
}

resource "tama_prompt" "movie-by-person-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Movie By Person Artifact"
  role     = "system"
  content  = file("tmdb-movie-by-person/artifact.md")
}

module "movie-by-person" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Movie By Person"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.movie-by-person-forwardable.class.id

  thread_classes = module.memovee.thread_classes

  routing_thought_relation = module.router.routing_thought_relation
  forwarding_relation      = local.forwarding_relation

  tool_call_model_id          = module.openai.model_ids["gpt-5.1-codex-mini"]
  tool_call_tool_choice       = "required"
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning = {
      effort = "low"
    }
    prompt_cache_retention = "24h"
  })

  tooling_prompt_id = tama_prompt.movie-by-person-tooling.id

  reply_prompt_id             = tama_prompt.movie-by-person-reply.id
  reply_artifact_prompt_id    = tama_prompt.movie-by-person-artifact.id
  reply_artifact_thought_id   = tama_modular_thought.reply-artifact.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index

  faculty_queue_id = tama_queue.conversation.id
  faculty_priority = 0
}

//
// Check User Preferences Tooling
//
resource "tama_thought_tool" "movie-by-person-check-user-preferences" {
  thought_id = module.movie-by-person.tooling_thought_id
  action_id  = data.tama_action.get-user-preferences.id
}

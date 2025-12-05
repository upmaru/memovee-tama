resource "tama_prompt" "person-detail-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Person Detail Tooling"
  role     = "system"
  content  = file("tmdb-person-detail/querying.md")
}

resource "tama_prompt" "person-detail-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Person Detail Reply"
  role     = "system"
  content  = file("tmdb-person-detail/reply.md")
}


resource "tama_prompt" "person-detail-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Person Detail Artifact"
  role     = "system"
  content  = file("tmdb-person-detail/artifact.md")
}

module "person-detail" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global,
    module.index-definition-generation
  ]

  name                        = "Person Detail"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.person-detail-forwardable.class.id

  thread_classes = module.memovee.thread_classes

  routing_thought_relation = module.router.routing_thought_relation
  forwarding_relation      = local.forwarding_relation

  tool_call_model_id          = module.openai.model_ids["gpt-5.1-codex-mini"]
  tool_call_tool_choice       = "required"
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning = {
      effort = "minimal"
    }
  })

  tooling_prompt_id = tama_prompt.person-detail-tooling.id

  reply_artifact_prompt_id  = tama_prompt.person-detail-artifact.id
  reply_artifact_thought_id = tama_modular_thought.reply-artifact.id

  reply_prompt_id             = tama_prompt.person-detail-reply.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.person-index
}

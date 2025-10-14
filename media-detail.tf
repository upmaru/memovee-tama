//
// Media Detail
//
resource "tama_prompt" "media-detail-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Media Detail Tooling"
  role     = "system"
  content  = file("media-detail/querying.md")
}

resource "tama_prompt" "media-detail-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Media Detail Reply"
  role     = "system"
  content  = file("media-detail/reply.md")
}

resource "tama_prompt" "media-detail-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Artifact Handling Prompt"
  role     = "system"
  content  = file("media-detail/artifact.md")
}

module "media-detail" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global.schemas,
    module.index-definition-generation
  ]

  name                        = "Media Detail"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.media-detail-forwardable.class.id

  thread_classes = module.memovee.thread_classes

  routing_thought_relation = module.router.routing_thought_relation
  forwarding_relation      = local.forwarding_relation

  tool_call_model_id          = module.openai.model_ids.gpt-5
  tool_call_model_temperature = 1.0
  tool_call_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })

  tooling_prompt_id = tama_prompt.media-detail-tooling.id

  reply_artifact_prompt_id  = tama_prompt.media-detail-artifact.id
  reply_artifact_thought_id = tama_modular_thought.reply-artifact.id

  reply_prompt_id             = tama_prompt.media-detail-reply.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.movie-index
}

module "watch-providers" {
  source = "./modules/watch-providers"

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
  thought_id = module.media-detail.tooling_thought_id
  action_id  = data.tama_action.get-user-preferences.id
}

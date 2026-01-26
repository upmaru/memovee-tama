//
// Person Browsing
//
resource "tama_prompt" "person-browse-tooling" {
  space_id = tama_space.media-conversation.id
  name     = "Person Browse Tooling"
  role     = "system"
  content  = file("tmdb-person-browsing/querying.md")
}

resource "tama_prompt" "person-browse-reply" {
  space_id = tama_space.media-conversation.id
  name     = "Person Browse Reply"
  role     = "system"
  content  = file("tmdb-person-browsing/reply.md")
}

resource "tama_prompt" "person-browse-artifact" {
  space_id = tama_space.media-conversation.id
  name     = "Person Browse Artifact"
  role     = "system"
  content  = file("tmdb-person-browsing/artifact.md")
}

resource "tama_prompt" "person-browse-routing" {
  space_id = tama_space.media-conversation.id
  name     = "Person Browse Routing"
  role     = "system"
  content  = file("tmdb-person-browsing/routing.md")
}

module "person-browsing" {
  source = "./modules/media-conversate"

  depends_on = [
    module.global,
    module.index-definition-generation
  ]

  name                        = "Person Browsing"
  media_conversation_space_id = tama_space.media-conversation.id
  target_class_id             = module.person-browsing-forwardable.class.id

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

  tooling_prompt_id = tama_prompt.person-browse-tooling.id

  reply_artifact_prompt_id  = tama_prompt.person-browse-artifact.id
  reply_artifact_thought_id = tama_modular_thought.reply-artifact.id

  reply_prompt_id             = tama_prompt.person-browse-reply.id
  reply_generation_thought_id = tama_modular_thought.reply-generation.id

  response_class_id = local.response_class_id

  movie_db_space_id                       = module.movie-db.space_id
  movie_db_elasticsearch_specification_id = module.movie-db.query_elasticsearch_specification_id

  index_definition_relation = module.index-definition-generation.relations.person-index

  faculty_queue_id = tama_queue.conversation.id
  faculty_priority = 0

  routeable_classes = {
    movie_browsing = module.movie-browsing-forwardable.class.id
  }

  router = {
    enabled = true
    parameters = {
      class_name = var.router_classification_class_name
      properties = var.router_classification_properties
      thread = {
        limit   = 7
        classes = module.memovee.thread_classes
        relations = {
          routing = "routing"
          focus   = ["tooling", "search-tooling", "reply"]
        }
      }
    }

    model_id          = module.openai.model_ids["gpt-5-mini"]
    model_temperature = 1.0
    model_parameters = jsonencode({
      reasoning_effort = "minimal"
    })

    prompt_id = tama_prompt.person-browse-routing.id
  }
}

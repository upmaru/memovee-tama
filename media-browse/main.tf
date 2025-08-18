resource "tama_prompt" "media-browsing-tooling" {
  space_id = var.media_conversation_space_id
  name     = "Media Browsing Tooling"
  role     = "system"
  content  = file("${path.module}/querying.md")
}

resource "tama_prompt" "media-browsing-reply" {
  space_id = var.media_conversation_space_id
  name     = "Media Browsing Reply"
  role     = "system"
  content  = file("${path.module}/reply.md")
}

resource "tama_chain" "browse-media" {
  space_id = var.media_conversation_space_id
  name     = "Browse Media"
}

resource "tama_modular_thought" "browse-media" {
  chain_id        = tama_chain.browse-media.id
  index           = 0
  relation        = "tooling"
  output_class_id = data.tama_class.action-call.id

  module {
    reference = "tama/agentic/tooling"
  }
}

resource "tama_thought_context" "browse-media" {
  thought_id = tama_modular_thought.browse-media.id
  prompt_id  = tama_prompt.media-browsing-tooling.id
}

resource "tama_thought_context_input" "browse-media-metadata" {
  thought_context_id = tama_thought_context.browse-media.id
  type               = "metadata"
  class_corpus_id    = data.tama_class_corpus.base-context-metadata.id
}

resource "tama_thought_context_input" "input-movie-index-definition" {
  thought_context_id = tama_thought_context.browse-media.id
  type               = "concept"
  class_corpus_id    = data.tama_class_corpus.index-definition-yaml.id
}

resource "tama_thought_processor" "browse-media" {
  thought_id = tama_modular_thought.browse-media.id
  model_id   = var.tool_call_model_id

  completion_config {
    temperature = 0.0
  }
}

resource "tama_thought_tool" "browse-media" {
  thought_id = tama_modular_thought.browse-media.id
  action_id  = data.tama_action.query-elasticsearch.id
}

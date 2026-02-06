resource "tama_space" "media-search" {
  name = "Media Search"
  type = "component"
}

resource "tama_space_bridge" "media-search-memovee-ui" {
  space_id        = tama_space.media-search.id
  target_space_id = tama_space.ui.id
}

module "media-search-forwarable" {
  source     = "upmaru/base/tama//modules/forwardable-class"
  version    = "0.5.2"
  depends_on = [module.global.schemas]

  space_id    = tama_space.media-search.id
  title       = "media-search"
  description = file("platform/media-search.md")
}

resource "tama_chain" "media-search" {
  space_id = tama_space.media-search.id
  name     = "Media Search"
}

resource "tama_modular_thought" "media-search-tooling" {
  chain_id        = tama_chain.media-search.id
  index           = 0
  relation        = "search-tooling"
  output_class_id = module.global.schemas.tool-call.id

  module {
    reference = "tama/agentic/tooling"
    parameters = jsonencode({
      consecutive_limit = 5
      thread = {
        limit   = 3
        classes = module.memovee-search.thread_classes
        relations = {
          routing = local.forwarding_relation
          focus   = ["search-tooling"]
        }
      }
    })
  }
}

data "tama_class" "context-metadata" {
  space_id = module.global.space.id
  name     = "context-metadata"
}

data "tama_class_corpus" "base-context-metadata" {
  class_id = data.tama_class.context-metadata.id
  slug     = "context-metadata"
}

resource "tama_prompt" "media-search-tooling" {
  space_id = tama_space.media-search.id
  name     = "Media Search Tooling"
  role     = "system"
  content  = file("platform-media-search/querying.md")
}

resource "tama_thought_context" "media-search-tooling" {
  thought_id = tama_modular_thought.media-search-tooling.id
  prompt_id  = tama_prompt.media-search-tooling.id
}

resource "tama_thought_context_input" "media-search-tooling-metadata" {
  thought_context_id = tama_thought_context.media-search-tooling.id
  type               = "metadata"
  class_corpus_id    = data.tama_class_corpus.base-context-metadata.id
}

resource "tama_thought_processor" "media-search-tooling-model" {
  thought_id = tama_modular_thought.media-search-tooling.id
  model_id   = module.groq.model_ids["openai/gpt-oss-20b"]

  completion {
    temperature = 1.0
    tool_choice = "required"
    parameters = jsonencode({
      reasoning_effort = "low"
    })
  }
}

resource "tama_thought_tool" "create-search-artifact-tool" {
  depends_on = [tama_space_bridge.media-search-memovee-ui]

  thought_id = tama_modular_thought.media-search-tooling.id
  action_id  = data.tama_action.create-search-artifact.id
}

resource "tama_node" "handle-media-search" {
  space_id = tama_space.media-search.id
  class_id = module.media-search-forwarable.class.id
  chain_id = tama_chain.media-search.id

  type = "reactive"
}

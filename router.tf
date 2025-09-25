module "router" {
  source  = "upmaru/base/tama//modules/router"
  version = "0.3.16"

  root_messaging_space_id = module.memovee.space.id
  author_class_name       = module.memovee.schemas.actor.name
  thread_class_name       = module.memovee.schemas.thread.name
  message_class_name      = module.memovee.schemas.user-message.name

  focus_relations = ["tooling", "search-tooling", "reply"]

  message_routing_class_id = module.global.schemas["message-routing"].id

  prompt = file("router/classify.md")

  routable_class_ids = [
    module.memovee.schemas["user-message"].id
  ]

  routing_model_id          = module.openai.model_ids.gpt-5-mini
  routing_model_temperature = 1.0
  routing_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })
}

resource "tama_thought_path" "route-to-off-topic" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.off-topic.id
}

resource "tama_thought_path" "route-to-introductory" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.introductory.id
}

resource "tama_thought_path" "route-to-curse" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.curse.id
}

resource "tama_thought_path" "route-to-greeting" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.greeting.id
}

resource "tama_thought_path" "route-to-manipulation" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.manipulation.id
}

resource "tama_thought_path" "route-to-patch" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.patch.id
}

resource "tama_thought_path" "route-to-personalization" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.personalization.id
}

resource "tama_thought_path" "route-to-media-conversation-classes" {
  for_each = module.media-conversation.class_ids

  thought_id      = module.router.routing_thought_id
  target_class_id = each.value
}

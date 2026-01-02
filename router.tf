module "router" {
  source  = "upmaru/base/tama//modules/router"
  version = "0.5.2"

  root_messaging_space_id = module.memovee.space_id
  author_class_name       = module.memovee.schemas.actor.name
  thread_class_name       = module.memovee.schemas.thread.name
  message_class_name      = module.memovee.schemas.user-message.name

  focus_relations = ["tooling", "search-tooling", "reply"]

  message_routing_class_id = module.global.schemas["message-routing"].id

  prompt = file("router/classify.md")

  routable_class_ids = [
    module.memovee.schemas["user-message"].id
  ]

  routing_model_id          = module.openai.model_ids["gpt-5-mini"]
  routing_model_temperature = 1.0
  routing_model_parameters = jsonencode({
    reasoning_effort = "minimal"
  })
}

resource "tama_thought_path" "route-to-off-topic" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.off-topic.class.id
}

resource "tama_thought_path" "route-to-introductory" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.introductory.class.id
}

resource "tama_thought_path" "route-to-curse" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.curse.class.id
}

resource "tama_thought_path" "route-to-greeting" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.greeting.class.id
}

resource "tama_thought_path" "route-to-manipulation" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.manipulation.class.id
}

resource "tama_thought_path" "route-to-patch" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.patch.class.id
}

resource "tama_thought_path" "route-to-personalization" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.personalization.class.id
}

resource "tama_thought_path" "route-to-marking" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.marking.class.id
}

resource "tama_thought_path" "route-to-movie-detail" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.movie-detail-forwardable.class.id
}

resource "tama_thought_path" "route-to-movie-browsing" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.movie-browsing-forwardable.class.id
}

resource "tama_thought_path" "route-to-person-detail" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.person-detail-forwardable.class.id
}

resource "tama_thought_path" "route-to-person-browsing" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.person-browsing-forwardable.class.id
}

resource "tama_thought_path" "route-to-movie-analytics" {
  thought_id      = module.router.routing_thought_id
  target_class_id = module.movie-analytics-forwardable.class.id
}

module "router" {
  source  = "upmaru/base/tama//modules/router"
  version = "0.2.38"

  root_messaging_space_id    = module.memovee.space.id
  network_message_thought_id = module.memovee.network_message_thought_id

  message_routing_class_id = module.global.schemas["message-routing"].id

  prompt = file("router/classify.md")

  routable_class_ids = [
    module.memovee.schemas["user-message"].id
  ]
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

resource "tama_thought_path" "route-to-media-conversation-classes" {
  for_each = module.media-conversation.class_ids

  thought_id      = module.router.routing_thought_id
  target_class_id = each.value
}

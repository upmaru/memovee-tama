module "router" {
  source  = "upmaru/base/tama//modules/router"
  version = "0.2.3"

  root_messaging_space_id = module.memovee.space.id

  actor_class_id  = module.memovee.schemas["actor"].id
  thread_class_id = module.memovee.schemas["thread"].id

  entity_network_class_id  = module.global.schemas["entity-network"].id
  message_routing_class_id = module.global.schemas["message-routing"].id

  prompt = file("${path.module}/router/classify.md")
}

resource "tama_node" "route-user-message" {
  space_id = module.memovee.space.id
  class_id = module.memovee.schemas["user-message"].id
  chain_id = module.router.chain_id

  type = "reactive"
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

resource "tama_thought_path" "route-to-media-detail" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.media-detail.id
}

resource "tama_thought_path" "route-to-media-browsing" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.media-browsing.id
}

resource "tama_thought_path" "route-to-person-detail" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.person-detail.id
}

resource "tama_thought_path" "route-to-person-browsing" {
  thought_id      = module.router.routing_thought_id
  target_class_id = tama_class.person-browsing.id
}

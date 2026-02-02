module "memovee-search" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.5.2"

  depends_on = [module.global.schemas]

  name = "Memovee Search"
}

resource "tama_space_bridge" "memovee-search-media-search" {
  space_id        = module.memovee-search.space_id
  target_space_id = tama_space.media-search.id
}


resource "tama_chain" "forward-to-media-search" {
  space_id = module.memovee-search.space_id
  name     = "Forward to Media Search"
}

resource "tama_modular_thought" "forward-to-media-search" {
  depends_on = [module.global.schemas]

  chain_id        = tama_chain.forward-to-media-search.id
  output_class_id = module.global.schemas.forwarding.id
  relation        = local.forwarding_relation
  index           = 0

  module {
    reference = "tama/concepts/forward"
  }
}

resource "tama_thought_path" "forward-to-media-search" {
  thought_id      = tama_modular_thought.forward-to-media-search.id
  target_class_id = module.media-search-forwarable.class.id
}

resource "tama_node" "forward-user-message" {
  space_id = module.memovee-search.space_id
  class_id = module.memovee-search.schemas["user-message"].id
  chain_id = tama_chain.forward-to-media-search.id

  type = "reactive"
}

//
// Listener Filters
//
resource "tama_listener_filter" "memovee-search-forwarding" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.forward-to-media-search.id
}

resource "tama_listener_filter" "memovee-search-media-search" {
  listener_id = tama_listener.memovee-ui-listener.id
  chain_id    = tama_chain.media-search.id
}

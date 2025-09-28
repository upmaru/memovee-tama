//
// Movie details indexing.
//
resource "tama_class_corpus" "movie-details-indexing" {
  class_id = data.tama_class.movie-details.id
  name     = "Movie Details Indexing"
  template = file("${path.module}/document-indexing.liquid")
}

data "tama_action" "index-document" {
  specification_id = var.elasticsearch_specification_id
  method           = "PUT"
  path             = "/{index}/_doc/{id}"
}

resource "tama_chain" "index-movie-details" {
  space_id = tama_space.movie-db.id
  name     = "Index Movie Details"
}

resource "tama_modular_thought" "index-movie-details" {
  chain_id = tama_chain.index-movie-details.id

  index    = 0
  relation = "index-movie-details"

  module {
    reference = "tama/actions/caller"
  }
}

module "movie-details-preloader" {
  source  = "upmaru/base/tama//modules/initializer-preload"
  version = "0.4.1"

  thought_id = tama_modular_thought.index-movie-details.id
  class_id   = data.tama_class.movie-details.id
  index      = 0

  concept_relations = [
    "description",
    "overview",
    "setting"
  ]

  concept_embeddings = "include"

  concept_content = {
    action = "merge"
    merge = {
      location = "root"
      name     = "merge"
    }
  }

  record_rejections = [
    { element = "value", matches = [""] }
  ]

  children = [
    {
      class = "movie-credits"
      as    = "object"
      record = {
        rejections = [
          { element = "value", matches = [""] }
        ]
      }
    }
  ]
}

resource "tama_thought_module_input" "index-movie-details" {
  thought_id      = tama_modular_thought.index-movie-details.id
  type            = "entity"
  class_corpus_id = tama_class_corpus.movie-details-indexing.id
}

resource "tama_thought_tool" "index-movie-details" {
  thought_id = tama_modular_thought.index-movie-details.id
  action_id  = data.tama_action.index-document.id
}

resource "tama_node" "index-movie-details-on-processed" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.movie-details.id
  chain_id = tama_chain.index-movie-details.id

  type = "reactive"
  on   = "processed"
}

resource "tama_node" "index-movie-details-explicit" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.movie-details.id
  chain_id = tama_chain.index-movie-details.id

  type = "explicit"
}

//
// Person details indexing.
//
resource "tama_class_corpus" "person-details-indexing" {
  class_id = data.tama_class.person-details.id
  name     = "Person Details Indexing"
  template = file("${path.module}/document-indexing.liquid")
}

resource "tama_chain" "index-person-details" {
  space_id = tama_space.movie-db.id
  name     = "Index Person Details"
}

resource "tama_modular_thought" "index-person-details" {
  chain_id = tama_chain.index-person-details.id

  index    = 0
  relation = "index-person-details"

  module {
    reference = "tama/actions/caller"
  }
}

module "person-details-preloader" {
  source  = "upmaru/base/tama//modules/initializer-preload"
  version = "0.4.1"

  thought_id = tama_modular_thought.index-person-details.id
  class_id   = data.tama_class.person-details.id
  index      = 0

  concept_relations = [
    "biography"
  ]

  concept_embeddings = "include"

  concept_content = {
    action = "merge"
    merge = {
      location = "root"
      name     = "merge"
    }
  }

  record_rejections = [
    { element = "value", matches = [""] }
  ]

  children = [
    {
      class = "person-combined-credits"
      as    = "object"
      record = {
        rejections = [
          { element = "value", matches = [""] }
        ]
      }
    }
  ]
}

resource "tama_thought_module_input" "index-person-details" {
  thought_id      = tama_modular_thought.index-person-details.id
  type            = "entity"
  class_corpus_id = tama_class_corpus.person-details-indexing.id
}

resource "tama_thought_tool" "index-person-details" {
  thought_id = tama_modular_thought.index-person-details.id
  action_id  = data.tama_action.index-document.id
}

resource "tama_node" "index-person-details-on-processed" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.person-details.id
  chain_id = tama_chain.index-person-details.id

  type = "reactive"
  on   = "processed"
}

resource "tama_node" "index-person-details-explicit" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.person-details.id
  chain_id = tama_chain.index-person-details.id

  type = "explicit"
}

//
// Class level indexing.
// After a given class operation is 'processed' it will run indexing for
// all the entities in the class.
//
resource "tama_chain" "index-class-entities" {
  space_id = tama_space.movie-db.id
  name     = "Index Class Entities"
}

resource "tama_modular_thought" "index-class-entities" {
  chain_id        = tama_chain.index-class-entities.id
  output_class_id = data.tama_class.task-result.id
  index           = 0
  relation        = "index-class-entities"

  module {
    reference = "tama/classes/process"
  }
}

resource "tama_thought_path" "index-movie-details-class" {
  thought_id      = tama_modular_thought.index-class-entities.id
  target_class_id = data.tama_class.movie-details.id
}

resource "tama_thought_path_activation" "index-movie-details-chain" {
  thought_path_id = tama_thought_path.index-movie-details-class.id
  chain_id        = tama_chain.index-movie-details.id
}

resource "tama_thought_path" "index-person-details-class" {
  thought_id      = tama_modular_thought.index-class-entities.id
  target_class_id = data.tama_class.person-details.id
}

resource "tama_thought_path_activation" "index-person-details-chain" {
  thought_path_id = tama_thought_path.index-person-details-class.id
  chain_id        = tama_chain.index-person-details.id
}

resource "tama_node" "handle-class-indexing" {
  space_id = tama_space.movie-db.id
  class_id = data.tama_class.class-proxy.id
  chain_id = tama_chain.index-class-entities.id

  type = "reactive"
  on   = "processed"
}

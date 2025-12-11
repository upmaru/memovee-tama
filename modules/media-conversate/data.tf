data "tama_space" "global" {
  id = "global"
}

data "tama_class" "tool-call" {
  space_id = data.tama_space.global.id
  name     = "tool-call"
}

data "tama_action" "query-elasticsearch" {
  specification_id = var.movie_db_elasticsearch_specification_id
  method           = "POST"
  path             = "/{index}/_search"
}

data "tama_class" "context-metadata" {
  space_id = data.tama_space.global.id
  name     = "context-metadata"
}

data "tama_class_corpus" "base-context-metadata" {
  class_id = data.tama_class.context-metadata.id
  slug     = "context-metadata"
}

data "tama_class" "index-definition" {
  space_id = var.movie_db_space_id
  name     = "index-definition"
}

data "tama_class_corpus" "index-definition-yaml" {
  class_id = data.tama_class.index-definition.id
  slug     = "index-definition-yaml"
}

data "tama_class" "text-based-vector-search" {
  specification_id = var.movie_db_elasticsearch_specification_id
  name             = "text-based-vector-search"
}

data "tama_class_corpus" "vector-search-request-body" {
  class_id = data.tama_class.text-based-vector-search.id
  slug     = "vector-search"
}

data "tama_class" "query-and-sort-based-search" {
  specification_id = var.movie_db_elasticsearch_specification_id
  name             = "query-and-sort-based-search"
}

data "tama_class_corpus" "standard-search-request-body" {
  class_id = data.tama_class.query-and-sort-based-search.id
  slug     = "standard-search"
}


data "tama_class" "forwarding" {
  space_id = data.tama_space.global.id
  name     = "forwarding"
}

data "tama_class" "message-routing" {
  space_id = data.tama_space.global.id
  name     = "message-routing"
}

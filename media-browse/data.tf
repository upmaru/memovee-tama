data "tama_space" "global" {
  id = "global"
}

data "tama_class" "action-call" {
  space_id = data.tama_space.global.id
  name     = "action-call"
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

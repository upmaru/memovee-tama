data "tama_space" "global" {
  id = "global"
}

data "tama_class" "collection" {
  space_id = data.tama_space.global.id
  name     = "collection"
}

data "tama_class" "class-proxy" {
  space_id = data.tama_space.global.id
  name     = "class-proxy"
}

data "tama_class" "movie-details" {
  specification_id = var.tmdb_specification_id
  name             = "movie-details"
}

data "tama_class" "person-details" {
  specification_id = var.tmdb_specification_id
  name             = "person-details"
}

data "tama_class_corpus" "collection-sampling" {
  class_id = data.tama_class.collection.id
  slug     = "sample-items"
}

data "tama_class" "elasticsearch-mapping" {
  space_id = var.elasticsearch_space_id
  name     = "elasticsearch-mapping"
}

data "tama_class_corpus" "elasticsearch-mapping" {
  class_id = data.tama_class.elasticsearch-mapping.id
  slug     = "elasticsearch-mapping"
}

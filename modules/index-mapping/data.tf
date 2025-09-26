data "tama_space" "global" {
  id = "global"
}

data "tama_class" "collection" {
  space_id = data.tama_space.global.id
  name     = "collection"
}

data "tama_class" "movie-details" {
  space_id = var.movie_db_space_id
  name     = "movie-details"
}

data "tama_class" "person-details" {
  space_id = var.movie_db_space_id
  name     = "person-details"
}

data "tama_class" "index-generation" {
  space_id = var.elasticsearch_space_id
  name     = "index-generation"
}

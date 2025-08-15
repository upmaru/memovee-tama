data "tama_space" "global" {
  id = "global"
}

data "tama_class" "answer" {
  space_id = data.tama_space.global.id
  name     = "answer"
}

data "tama_class" "class-proxy" {
  space_id = data.tama_space.global.id
  name     = "class-proxy"
}

data "tama_class" "task-result" {
  space_id = data.tama_space.global.id
  name     = "task-result"
}

data "tama_class_corpus" "answer-content" {
  class_id = data.tama_class.answer.id
  slug     = "answer-content"
}

data "tama_class" "person-details" {
  specification_id = tama_specification.tmdb.id
  name             = "person-details"
}

data "tama_class" "movie-credits" {
  specification_id = tama_specification.tmdb.id
  name             = "movie-credits"
}

data "tama_class" "movie-details" {
  specification_id = tama_specification.tmdb.id
  name             = "movie-details"
}

data "tama_action" "get-movie-credits" {
  specification_id = tama_specification.tmdb.id
  method           = "GET"
  path             = "/3/movie/{movie_id}/credits"
}

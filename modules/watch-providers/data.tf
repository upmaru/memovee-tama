data "tama_action" "watch-providers" {
  specification_id = var.tmdb_specification_id
  method           = "GET"
  path             = "/3/movie/{movie_id}/watch/providers"
}

data "tama_class" "watch-providers" {
  specification_id = var.tmdb_specification_id
  name             = "movie-watch-providers"
}

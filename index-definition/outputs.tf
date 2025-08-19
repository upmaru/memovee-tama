output "relations" {
  value = {
    movie-index  = local.movie_db_index_definition_relation
    person-index = local.person_db_index_definition_relation
  }
  description = "The relation of the concept for movie db index definition"
}

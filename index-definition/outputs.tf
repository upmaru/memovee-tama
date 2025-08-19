output "relations" {
  value = {
    movie-db  = local.movie_db_index_definition_relation
    person-db = local.person_db_index_definition_relation
  }
  description = "The relation of the concept for movie db index definition"
}

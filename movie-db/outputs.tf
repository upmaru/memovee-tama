output "space_id" {
  value       = tama_space.movie-db.id
  description = "The ID of the movie-db space"
}

output "tmdb_specification_id" {
  value       = tama_specification.tmdb.id
  description = "The ID of the tmdb specification"
}

output "query_elasticsearch_specification_id" {
  value       = tama_specification.movie-db-query-elasticsearch.id
  description = "The ID of the query-elasticsearch specification"
}

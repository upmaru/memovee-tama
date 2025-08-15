variable "movie_db_space_id" {
  type        = string
  description = "The ID of the Tama space where the index will be created"
}

variable "tmdb_specification_id" {
  type        = string
  description = "The ID of the TMDB specification to use for index definition generation"
}

variable "elasticsearch_space_id" {
  type        = string
  description = "The ID of the Elasticsearch space where the index will be created"
}

variable "model_id" {
  type        = string
  description = "The ID of the model to use for index definition generation"
}

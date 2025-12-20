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

variable "elasticsearch_specification_id" {
  type        = string
  description = "The ID of Elasticsearch specification for managing the elasticsearch cluster"
}

variable "index_definition_generation_model_id" {
  type        = string
  description = "The ID of the model to use for index definition generation"
}

variable "index_definition_generation_model_temperature" {
  type        = number
  default     = 0.0
  description = "The temperature to use for index definition generation"
}

variable "index_definition_generation_model_parameters" {
  type        = string
  description = "The parameters to use for index definition generation"
}

variable "create_index_relation" {
  type        = string
  description = "The relation of concept used for index creation"
}

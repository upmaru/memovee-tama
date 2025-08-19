variable "media_conversation_space_id" {
  type        = string
  description = "The ID of the space for the media conversation."
}

variable "movie_db_space_id" {
  type        = string
  description = "The ID of the space for the movie database."
}

variable "movie_db_elasticsearch_specification_id" {
  type        = string
  description = "The ID of the Elasticsearch specification for the movie database."
}

variable "prompt_assembly_space_id" {
  type        = string
  description = "The ID of the space for the prompt assembly."
}

variable "tool_call_model_id" {
  type        = string
  description = "The ID of the model for the tool call."
}

variable "index_definition_relation" {
  type        = string
  description = "The relation of the index definition to the movie database."
}

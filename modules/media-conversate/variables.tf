variable "name" {
  type        = string
  description = "The name of the media conversation chain."
}

variable "media_conversation_space_id" {
  type        = string
  description = "The ID of the space for the media conversation."
}

variable "target_class_id" {
  type        = string
  description = "The ID of the class for the target."
}

variable "movie_db_space_id" {
  type        = string
  description = "The ID of the space for the movie database."
}

variable "movie_db_elasticsearch_specification_id" {
  type        = string
  description = "The ID of the Elasticsearch specification for the movie database."
}

variable "response_class_id" {
  type        = string
  description = "The ID of the class for the response."
}

variable "tool_call_model_id" {
  type        = string
  description = "The ID of the model for the tool call."
}

variable "tool_call_model_temperature" {
  type        = number
  description = "The temperature parameter of the tool call model"
  default     = 0.0
}

variable "tool_call_model_parameters" {
  type        = string
  description = "The parameters of the tool call model"
}

variable "index_definition_relation" {
  type        = string
  description = "The relation of the index definition to the movie database."
}

variable "tooling_prompt_id" {
  type        = string
  description = "The ID of the prompt for the tooling."
}

variable "reply_artifact_prompt_id" {
  type        = string
  description = "The ID of the prompt for the artifact."
}

variable "reply_prompt_id" {
  type        = string
  description = "The ID of the prompt for the reply."
}

variable "routing_thought_relation" {
  type        = string
  description = "The relation of the routing thought to the movie database."
}

variable "thread_classes" {
  type = object({
    author  = string
    thread  = string
    message = string
  })
  description = "The names of the author, thread, message classes."
}

variable "forwarding_relation" {
  type        = string
  description = "The relation for forwarding thoughts."
}

variable "reply_artifact_thought_id" {
  type        = string
  description = "The ID of the thought for reply artifact."
}

variable "reply_generation_thought_id" {
  type        = string
  description = "The ID of the thought for reply generation."
}

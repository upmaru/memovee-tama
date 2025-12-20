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

variable "tool_call_tool_choice" {
  type        = string
  description = "Tool choice setting for model valid choices: required, any, auto"
  default     = "required"
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

variable "thread_limit" {
  type        = number
  description = "The limit of the thread."
  default     = 5
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

variable "faculty_queue_id" {
  type        = string
  description = "The Queue ID to use for the thoughts"
  default     = null
}

variable "faculty_priority" {
  type        = number
  description = "The priority for the thoughts"
  default     = 1
}

variable "router" {
  type        = any
  description = "Configuration for enabling tama/agentic/router for forwarding."
  default = {
    enabled = false
  }

  validation {
    condition = (
      var.router == null ||
      lookup(var.router, "enabled", false) == false ||
      (
        try(var.router.parameters, null) != null &&
        try(var.router.prompt_id, null) != null &&
        try(var.router.model_id, null) != null &&
        try(var.router.model_temperature, null) != null &&
        try(var.router.model_parameters, null) != null
      )
    )
    error_message = "When router.enabled is true, provide parameters, prompt_id, model_id, model_temperature, and model_parameters."
  }
}

variable "routeable_classes" {
  type        = map(string)
  description = "Static-key map of routable class IDs for the router (keys must be known at plan time)."
  default     = {}

  validation {
    condition = (
      try(var.router.enabled, false) == false ||
      length(var.routeable_classes) > 0
    )
    error_message = "Provide a non-empty routeable_classes map when router.enabled is true."
  }
}

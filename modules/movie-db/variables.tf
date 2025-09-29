variable "tmdb_api_key" {
  type        = string
  description = "TMDB API key"
}

variable "tmdb_openapi_url" {
  type        = string
  description = "TMDB OpenAPI URL"
}

variable "elasticsearch_endpoint" {
  type        = string
  description = "Elasticsearch Endpoint"
}

variable "elasticsearch_api_key" {
  type        = string
  description = "Elasticsearch API Key"
}

variable "elasticsearch_space_id" {
  type        = string
  description = "Elasticsearch Space ID"
}

variable "elasticsearch_specification_id" {
  type        = string
  description = "Elasticsearch Specification ID"
}

variable "elasticsearch_query_schema" {
  type        = string
  description = "Elasticsearch Query Schema"
}

variable "generate_description_model_id" {
  type        = string
  description = "The model to use for generating movie descriptions"
}

variable "generate_description_model_parameters" {
  type        = string
  description = "The parameters to use for generating movie descriptions"
}

variable "generate_description_model_temperature" {
  type        = number
  description = "The temperature to use for generating movie descriptions"
  default     = 1.0
}

variable "generate_setting_model_id" {
  type        = string
  description = "The model to use for generating movie settings"
}

variable "generate_setting_model_parameters" {
  type        = string
  description = "The parameters to use for generating movie settings"
}

variable "generate_setting_model_temperature" {
  type        = number
  description = "The temperature to use for generating movie settings"
  default     = 1.0
}

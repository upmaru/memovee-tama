variable "space_id" {
  type        = string
  description = "The Space ID to use for the chain"
}

variable "name" {
  type        = string
  description = "The name of the chain"
}

variable "fields" {
  type        = list(string)
  description = "Name of the fields to spread"
}

variable "identifier" {
  type        = string
  description = "Name of the identifier to use for the fields"
  default     = "id"
}

variable "class_ids" {
  type        = list(string)
  description = "List of class IDs to use for the chain"
}

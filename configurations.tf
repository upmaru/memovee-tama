variable "tama_base_url" {
  type        = string
  description = "The base URL of the Tama API"
}

variable "tama_client_id" {
  type        = string
  description = "The client ID for the Tama API"
}

variable "tama_client_secret" {
  type        = string
  description = "The client secret for the Tama API"
}

provider "tama" {}

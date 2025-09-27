variable "tama_base_url" {
  type        = string
  description = "The base URL of the Tama API"
}

variable "tama_api_key" {
  type        = string
  description = "The API key for the Tama API"
}

provider "tama" {
  base_url = var.tama_base_url
  api_key  = var.tama_api_key
}

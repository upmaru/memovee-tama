variable "tama_base_url" {}
variable "tama_api_key" {}

provider "tama" {
  base_url = var.tama_base_url
  api_key  = var.tama_api_key
}

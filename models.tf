variable "mistral_api_key" {}
module "mistral" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.1.2"

  space_id = data.tama_space.global.id
  api_key  = var.mistral_api_key
  endpoint = "https://api.mistral.ai/v1"
  name     = "mistral"

  requests_per_second = 6

  models = [
    {
      identifier = "mistral-medium-latest"
      path       = "/chat/completions"
    },
    {
      identifier = "mistral-small-latest"
      path       = "/chat/completions"
    }
  ]
}

variable "xai_api_key" {}
module "xai" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.1.2"

  space_id = data.tama_space.global.id
  api_key  = var.xai_api_key
  endpoint = "https://api.x.ai/v1"
  name     = "xai"

  requests_per_second = 4

  models = [
    {
      identifier = "grok-3-mini"
      path       = "/chat/completions"
    },
    {
      identifier = "grok-3-mini-fast"
      path       = "/chat/completions"
    }
  ]
}

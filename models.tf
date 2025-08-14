variable "mistral_api_key" {}
module "mistral" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.2.28"

  space_id = module.global.space.id
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
  version = "0.2.28"

  space_id = module.global.space.id
  api_key  = var.xai_api_key
  endpoint = "https://api.x.ai/v1"
  name     = "xai"

  requests_per_second = 4

  models = [
    {
      identifier = "grok-3-mini"
      path       = "/chat/completions",
      parameters = {
        reasoning_effort = "high"
      }
    },
    {
      identifier = "grok-3-mini-fast"
      path       = "/chat/completions",
      parameters = {
        reasoning_effort = "low"
      }
    }
  ]
}

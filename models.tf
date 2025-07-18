variable "mistral_api_key" {}
resource "tama_source" "mistral" {
  space_id = data.tama_space.global.id
  api_key  = var.mistral_api_key
  endpoint = "https://api.mistral.ai"
  name     = "mistral"
  type     = "model"
}

resource "tama_limit" "mistral" {
  source_id   = tama_source.mistral.id
  scale_count = 1
  scale_unit  = "seconds"
  value       = 6
}

resource "tama_model" "mistral-medium" {
  source_id  = tama_source.mistral.id
  identifier = "mistral-medium-latest"
  path       = "/v1/chat/completions"
}

resource "tama_model" "mistral-small" {
  source_id  = tama_source.mistral.id
  identifier = "mistral-small-latest"
  path       = "/v1/chat/completions"
}

variable "xai_api_key" {}
resource "tama_source" "xai" {
  space_id = data.tama_space.global.id
  api_key  = var.xai_api_key
  endpoint = "https://api.x.ai"
  name     = "xai"
  type     = "model"
}

resource "tama_limit" "xai" {
  source_id   = tama_source.xai.id
  scale_count = 1
  scale_unit  = "seconds"
  value       = 4
}

resource "tama_model" "grok-3-mini" {
  source_id  = tama_source.xai.id
  identifier = "grok-3-mini"
  path       = "/v1/chat/completions"
  parameters = jsonencode({
    reasoning_effort = "high"
  })
}

resource "tama_model" "grok-3-mini-fast" {
  source_id  = tama_source.xai.id
  identifier = "grok-3-mini-fast"
  path       = "/v1/chat/completions"
  parameters = jsonencode({
    reasoning_effort = "low"
  })
}

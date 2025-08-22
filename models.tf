variable "mistral_api_key" {}
module "mistral" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.3.1"

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
  version = "0.3.1"

  space_id = module.global.space.id
  api_key  = var.xai_api_key
  endpoint = "https://api.x.ai/v1"
  name     = "xai"

  requests_per_second = 4

  models = [
    {
      identifier = "grok-3-mini"
      path       = "/chat/completions",
      parameters = jsonencode({
        reasoning_effort = "high"
      })
    },
    {
      identifier = "grok-3-mini-fast"
      path       = "/chat/completions",
      parameters = jsonencode({
        reasoning_effort = "low"
      })
    }
  ]
}

variable "openai_api_key" {}
module "openai" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.3.1"

  space_id = module.global.space.id
  api_key  = var.openai_api_key
  endpoint = "https://api.openai.com/v1"
  name     = "openai"

  requests_per_second = 10

  models = [
    {
      identifier = "gpt-5-mini"
      path       = "/chat/completions"
      parameters = jsonencode({
        reasoning_effort = "high"
      })
    },
    {
      identifier = "gpt-5-nano"
      path       = "/chat/completions"
      parameters = jsonencode({
        reasoning_effort = "low"
      })
    }
  ]
}

variable "azure_api_key" {}
module "azure" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.3.1"

  space_id = module.global.space.id
  api_key  = var.azure_api_key
  endpoint = "https://tama-dev-resource.openai.azure.com/openai/deployments"
  name     = "azure-ai-foundry"

  requests_per_second = 10

  models = [
    {
      identifier = "gpt-5-mini"
      path       = "/gpt-5-mini/chat/completions?api-version=2025-01-01-preview"
      parameters = jsonencode({
        reasoning_effort = "high"
      })
    }
  ]
}

module "arrakis" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.3.1"

  space_id = module.global.space.id
  api_key  = "dummy"
  endpoint = "https://models.arrakis.upmaru.network"
  name     = "arrakis"

  requests_per_second = 32

  models = [
    {
      identifier = "qwen-3-30b-a3b"
      path       = "/v1/chat/completions"
      parameters = jsonencode({
        temperature = 0.7
      })
    },
    {
      identifier = "gpt-oss"
      path       = "/v1/chat/completions"
      parameters = jsonencode({
        temperature      = 0.7
        reasoning_effort = "medium"
      })
    },
    {
      identifier = "qwen-3-14b"
      path       = "/v1/chat/completions"
      parameters = jsonencode({
        temperature = 0.7
      })
    },
    {
      identifier = "intfloat/multilingual-e5-large-instruct"
      path       = "/embeddings"
    },
    {
      identifier = "mixedbread-ai/mxbai-rerank-large-v1"
      path       = "/rerank"
    }
  ]
}

resource "tama_space_processor" "default-completion" {
  space_id = module.global.space.id
  model_id = module.arrakis.model_ids.qwen-3-14b

  completion {
    temperature = 0.7
  }
}

resource "tama_space_processor" "default-embedding" {
  space_id = module.global.space.id
  model_id = module.arrakis.model_ids["intfloat/multilingual-e5-large-instruct"]

  embedding {
    max_tokens = 512
    templates = [{
      type    = "query"
      content = <<-EOT
      Instruct: {{ instruction }}
      Query: {{ query }}
      EOT
    }]
  }
}

resource "tama_space_processor" "default-reranking" {
  space_id = module.global.space.id
  model_id = module.arrakis.model_ids["mixedbread-ai/mxbai-rerank-large-v1"]

  reranking {
    top_n = 3
  }
}

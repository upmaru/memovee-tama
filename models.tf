variable "mistral_api_key" {
  type        = string
  description = "The API key for the Mistral inference service"
}

module "mistral" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.4.3"

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

variable "xai_api_key" {
  type        = string
  description = "The API key for the XAI inference service"
}

module "xai" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.4.3"

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
    },
    {
      identifier = "grok-code-fast-1"
      path       = "/chat/completions",
      parameters = jsonencode({})
    },
    {
      identifier = "grok-4-fast-non-reasoning"
      path       = "/chat/completions",
      parameters = jsonencode({})
    },
    {
      identifier = "grok-4-fast-reasoning"
      path       = "/chat/completions",
      parameters = jsonencode({})
    },
  ]
}

variable "openai_api_key" {
  type        = string
  description = "The API key for the OpenAI inference service"
}

module "openai" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.4.3"

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
    },
    {
      identifier = "gpt-5"
      path       = "/chat/completions"
      parameters = jsonencode({
        reasoning_effort = "low"
      })
    }
  ]
}

variable "anthropic_api_key" {
  type        = string
  description = "The API key for the Anthropic inference service"
}

module "anthropic" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.4.3"

  space_id = module.global.space.id
  api_key  = var.anthropic_api_key
  endpoint = "https://api.anthropic.com/v1"
  name     = "anthropic"

  requests_per_second = 10

  models = [
    {
      identifier = "claude-sonnet-4-5"
      path       = "/chat/completions"
      parameters = jsonencode({})
    },
    {
      identifier = "claude-haiku-4-5"
      path       = "/chat/completions"
      parameters = jsonencode({})
    }
  ]
}

variable "voyageai_api_key" {
  type        = string
  description = "The API key for the VoyageAI inference service"
}

module "voyageai" {
  source  = "upmaru/base/tama//modules/inference-service"
  version = "0.4.3"

  space_id = module.global.space.id
  api_key  = var.voyageai_api_key
  endpoint = "https://api.voyageai.com"
  name     = "voyageai"

  requests_per_second = 32

  models = [
    {
      identifier = "voyage-3.5"
      path       = "/v1/embeddings"
      parameters = jsonencode({
        output_dimension = 1024
      })
    },
    {
      identifier = "rerank-2.5"
      path       = "/v1/rerank"
      parameters = jsonencode({
        top_k = 5
      })
    }
  ]
}


resource "tama_space_processor" "default-completion" {
  space_id = module.global.space.id
  model_id = module.openai.model_ids.gpt-5-nano

  completion {
    temperature = 1.0
    parameters = jsonencode({
      reasoning_effort = "minimal"
      service_tier     = "flex"
    })
  }
}

resource "tama_space_processor" "default-embedding" {
  space_id = module.global.space.id
  model_id = module.voyageai.model_ids["voyage-3.5"]

  embedding {
    max_tokens = 512
  }
}

resource "tama_space_processor" "default-reranking" {
  space_id = module.global.space.id
  model_id = module.voyageai.model_ids["rerank-2.5"]

  reranking {
    parameters = jsonencode({
      top_k = 5
    })
  }
}

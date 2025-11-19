resource "tama_space" "ui" {
  name = "Memovee UI"
  type = "component"
}

variable "memovee_ui_endpoint" {
  type        = string
  description = "The endpoint URL of the Memovee UI"
}

variable "memovee_ui_openapi_url" {
  type        = string
  description = "The OpenAPI URL of the Memovee UI"
}

resource "tama_specification" "memovee-ui" {
  space_id = tama_space.ui.id

  endpoint = var.memovee_ui_endpoint
  version  = "0.1.2"
  schema   = jsonencode(jsondecode(data.http.memovee-ui.response_body))

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

variable "memovee_ui_client_id" {
  type        = string
  description = "The client ID for the Memovee UI OAuth client"
}

variable "memovee_ui_client_secret" {
  type        = string
  description = "The client secret for the Memovee UI OAuth client"
}

resource "tama_source_identity" "memovee-ui-oauth" {
  specification_id = tama_specification.memovee-ui.id
  identifier       = "oauth"

  client_id     = var.memovee_ui_client_id
  client_secret = var.memovee_ui_client_secret

  validation {
    path   = "/tama/health"
    method = "GET"
    codes  = [200]
  }

  wait_for {
    field {
      name = "current_state"
      in   = ["active", "failed"]
    }
  }
}

data "http" "memovee-ui" {
  url = var.memovee_ui_openapi_url
}

data "tama_action" "create-artifact" {
  specification_id = tama_specification.memovee-ui.id
  method           = "POST"
  path             = "/tama/conversation/messages/{message_id}/artifacts"
}

data "tama_action" "get-user-preferences" {
  specification_id = tama_specification.memovee-ui.id
  method           = "GET"
  path             = "/tama/accounts/users/{user_id}/preferences"
}

data "tama_action" "create-user-preference" {
  specification_id = tama_specification.memovee-ui.id
  method           = "POST"
  path             = "/tama/accounts/users/{user_id}/preferences"
}

data "tama_action" "update-user-preference" {
  specification_id = tama_specification.memovee-ui.id
  method           = "PUT"
  path             = "/tama/accounts/users/{user_id}/preferences/{id}"
}

data "tama_action" "get-user" {
  specification_id = tama_specification.memovee-ui.id
  method           = "GET"
  path             = "/tama/accounts/users/{id}"
}

data "tama_action" "update-user" {
  specification_id = tama_specification.memovee-ui.id
  method           = "PUT"
  path             = "/tama/accounts/users/{id}"
}

data "tama_action" "create-record-markings" {
  specification_id = tama_specification.memovee-ui.id
  method           = "POST"
  path             = "/tama/content/users/{user_id}/markings"
}

data "tama_action" "list-record-markings" {
  specification_id = tama_specification.memovee-ui.id
  method           = "GET"
  path             = "/tama/content/users/{user_id}/markings"
}

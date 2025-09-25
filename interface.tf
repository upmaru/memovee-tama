resource "tama_space" "ui" {
  name = "Memovee UI"
  type = "component"
}

variable "memovee_ui_endpoint" {}
variable "memovee_ui_openapi_url" {}
data "http" "memovee-ui" {
  url = var.memovee_ui_openapi_url
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

variable "memovee_ui_client_id" {}
variable "memovee_ui_client_secret" {}
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

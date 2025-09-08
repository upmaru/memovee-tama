resource "tama_space" "ui" {
  name = "Memovee UI"
  type = "component"
}

variable "memovee_ui_version" {}
variable "memovee_ui_endpoint" {}
resource "tama_specification" "ui" {
  space_id = tama_space.ui.id

  version  = "0.1.0"
  endpoint = var.memovee_ui_endpoint
  schema = jsonencode(yamldecode(templatefile("memovee-ui/specification.yml", {
    memovee_ui_endpoint = var.memovee_ui_endpoint,
    memovee_ui_version  = var.memovee_ui_version
  })))

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

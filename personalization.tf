resource "tama_space" "personalization" {
  name = "Personalization"
  type = "component"
}

resource "tama_specification" "personalization-spec" {
  space_id = tama_space.personalization.id
  endpoint = "/internal/personalization"
  version  = "1.0.0"

  schema = jsonencode(yamldecode(file("${path.module}/personalization/specification.yaml")))

  wait_for {
    field {
      name = "current_state"
      in   = ["completed", "failed"]
    }
  }
}

data "tama_action" "get-profile" {
  specification_id = tama_specification.personalization-spec.id
  identifier       = "get-profile"
}

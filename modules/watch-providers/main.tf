resource "tama_class_corpus" "watch-providers-output" {
  class_id = data.tama_class.watch-providers.id
  name     = "Watch Provider Output"
  template = file("${path.module}/output.liquid")
}

resource "tama_action_modifier" "region-modifier" {
  action_id = data.tama_action.watch-providers.id
  name      = "region"
  schema = jsonencode({
    type        = "string"
    description = "The ISO 3166-1 alpha-2 region the user is in."
  })
}

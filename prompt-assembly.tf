resource "tama_space" "prompt-assembly" {
  name = "Prompt Assembly"
  type = "component"
}

resource "tama_class" "context-component" {
  space_id   = tama_space.prompt-assembly.id
  depends_on = [module.global]
  schema_json = jsonencode(
    jsondecode(file("${path.module}/prompt-assembly/context-component.json"))
  )
}

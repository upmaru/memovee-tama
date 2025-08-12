resource "tama_chain" "this" {
  space_id = var.space_id
  name     = var.name
}

resource "tama_modular_thought" "this" {
  chain_id = tama_chain.this.id

  index    = 0
  relation = "spread"

  module {
    reference = "tama/entities/spread"
    parameters = jsonencode({
      fields     = var.fields
      identifier = var.identifier
    })
  }
}

resource "tama_thought_path" "this" {
  count = length(var.class_ids)

  thought_id      = tama_modular_thought.this.id
  target_class_id = var.class_ids[count.index]
}

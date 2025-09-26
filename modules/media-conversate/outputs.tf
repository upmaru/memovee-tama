output "tooling_thought_id" {
  value       = tama_modular_thought.tooling.id
  description = "The ID of the tooling thought"
}

output "chain_id" {
  value       = tama_chain.this.id
  description = "The ID of the chain"
}

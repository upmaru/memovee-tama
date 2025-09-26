output "class_corpus_id" {
  value       = tama_class_corpus.watch-providers-output.id
  description = "The watch provider corpus id for outputting watch data."
}

output "action_id" {
  value = data.tama_action.watch-providers.id
}

output "action_modifier_id" {
  value       = tama_action_modifier.region-modifier.id
  description = "The watch provider action modifier id for modifying watch data."
}

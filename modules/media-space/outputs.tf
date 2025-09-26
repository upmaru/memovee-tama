output "space_id" {
  value       = tama_space.this.id
  description = "The space ID"
}

output "class_ids" {
  value = {
    media-detail    = tama_class.media-detail.id,
    media-browsing  = tama_class.media-browsing.id,
    person-detail   = tama_class.person-detail.id,
    person-browsing = tama_class.person-browsing.id
  }

  description = "Classes from media-conversation space"
}

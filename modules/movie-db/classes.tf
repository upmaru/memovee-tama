resource "tama_class" "memovee-movie-watch-providers" {
  space_id = tama_space.movie-db.id

  schema {
    title       = "memovee-movie-watch-providers"
    description = <<-EOT
    Watch provider data formatted in a way that's easy to query in elasticsearch.
    EOT
    type        = "object"
    properties = jsonencode({
      id = {
        type        = "integer"
        description = "The TMDB movie ID associated with these watch providers."
      }
      parent_entity_id = {
        type        = "string"
        description = "Identifier of the parent movie entity inside Tama."
      }
      watch_providers = {
        type        = "array"
        description = "Region-specific watch provider availability entries."
        items = {
          type = "object"
          properties = {
            country = {
              type        = "string"
              description = "ISO 3166-1 alpha-2 code for the provider's country."
            }
            type = {
              type        = "string"
              description = "Type of availability such as flatrate, rent, or buy."
            }
            provider_id = {
              type        = "integer"
              description = "TMDB identifier of the provider."
            }
            provider_name = {
              type        = "string"
              description = "Human-readable provider name."
            }
            display_priority = {
              type        = "integer"
              description = "Provider display order within the region."
            }
          }
          required = [
            "country",
            "type",
            "provider_id",
            "provider_name",
            "display_priority"
          ]
        }
      }
    })
  }
}

## Movie DB Specific Constraints
- The ID should be of the type `long`.
- Make sure the following fields are of type `nested`:
  - `genres`
  - `production_companies`
  - `movie-credits.cast`
  - `movie-credits.crew`
  - `memovee-movie-watch-providers.watch_providers`
- The `watch_providers` nested object must expose the following mapping so every property is explicitly typed:
  ```json
  {
    "watch_providers": {
      "type": "nested",
      "properties": {
        "country": { "type": "keyword" },
        "type": { "type": "keyword" },
        "logo_path": { "type": "keyword" },
        "provider_id": { "type": "integer" },
        "provider_name": { "type": "keyword" },
        "display_priority": { "type": "integer" }
      }
    }
  }
  ```
- When validating `watch_providers` documents, expect entries similar to:
  ```json
  {
    "country": "MK",
    "display_priority": 0,
    "logo_path": "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg",
    "provider_id": 8,
    "provider_name": "Netflix",
    "type": "flatrate"
  }
  ```
- Make sure that the following fields are of type `text`:
  - `title`
  - `original_title`
  - `overview`
  - `movie-credits.cast.character`
  - `movie-credits.cast.name`
  - `movie-credits.cast.original_name`
  - `movie-credits.crew.job`
  - `movie-credits.crew.name`
  - `movie-credits.crew.original_name`
  - `movie-credits.crew.department`
  - `movie-credits.crew.known_for_department`
- Make sure that the following fields are of type `keyword`:
  - `genres.name`
  - `status`
  - `imdb_id`
  - `metadata.class`
  - `metadata.space`
- **NEVER** make up mapping for fields that do not exist.
  - Example: If a field name is `movie-credits`, **NEVER** convert it to `movie_credits`.

resource "tama_prompt" "movie-db-index-constraints" {
  space_id = var.movie_db_space_id
  name     = "Generate Movie DB Index"
  role     = "user"
  content  = file("${path.module}/movie-db.md")
}

resource "tama_prompt" "person-db-index-constraints" {
  space_id = var.movie_db_space_id
  name     = "Generate Person DB Index"
  role     = "user"
  content  = file("${path.module}/person-db.md")
}

module "sample-movies-for-index-generation" {
  source  = "upmaru/base/tama//modules/sample-forward-entities"
  version = "0.3.2"

  space_id = var.movie_db_space_id
  name     = "Sample for Movie Index Generation"

  limit               = 3
  ensure_chunk_exists = true

  preload_concept_with_relations = ["description", "overview", "setting"]
  preload_children = [
    {
      class = "movie-credits",
      as    = "object",
      record = {
        rejections = [
          { element = "value", matches = [""] }
        ]
      }
    }
  ]

  target_class_id = data.tama_class.movie-details.id
  prompt_id       = tama_prompt.movie-db-index-constraints.id

  forward_to_class_id = data.tama_class.index-generation.id
}

module "sample-people-for-index-generation" {
  source  = "upmaru/base/tama//modules/sample-forward-entities"
  version = "0.3.2"

  space_id = var.movie_db_space_id
  name     = "Sample for Person Index Generation"

  limit               = 3
  ensure_chunk_exists = true

  preload_concept_with_relations = ["biography"]
  preload_children = [
    {
      class = "person-combined-credits",
      as    = "object",
      record = {
        rejections = [
          { element = "value", matches = [""] }
        ]
      }
    }
  ]

  target_class_id = data.tama_class.person-details.id
  prompt_id       = tama_prompt.person-db-index-constraints.id

  forward_to_class_id = data.tama_class.index-generation.id
}

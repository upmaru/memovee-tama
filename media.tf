module "media-conversation" {
  source = "./modules/media-space"

  depends_on = [module.global.schemas]

  movie_db_space_id        = module.movie-db.space_id
  prompt_assembly_space_id = tama_space.prompt-assembly.id
  memovee_ui_space_id      = tama_space.ui.id
}

module "media-conversation" {
  source = "./modules/media-space"

  depends_on = [module.global.schemas]

  movie_db_space_id   = module.movie-db.space_id
  memovee_space_id    = module.memovee.space.id
  memovee_ui_space_id = tama_space.ui.id
}

data "tama_space" "global" {
  id = "global"
}

data "tama_class" "tool-call" {
  space_id = data.tama_space.global.id
  name     = "tool-call"
}

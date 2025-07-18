data "tama_space" "global" {
  id = "global"
}

resource "tama_space" "memovee" {
  name = "memovee"
  type = "root"
}

resource "tama_prompt" "memovee" {
  space_id = tama_space.memovee.id

  name    = "Memovee Personality"
  role    = "system"
  content = file("${path.module}/prompts/memovee/main.md")
}

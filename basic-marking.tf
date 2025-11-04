resource "tama_chain" "handle-marking" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Marking"
}

resource "tama_prompt" "handle-marking" {
  space_id = tama_space.basic-conversation.id
  name     = "Handle Marking"
  role     = "system"
  content  = file("basic-marking/tooling.md")
}

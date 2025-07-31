resource "tama_space" "basic-conversation" {
  name = "Basic Conversation"
  type = "component"
}

resource "tama_class" "off-topic" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/off-topic.json")))
}

resource "tama_class" "greeting" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/greeting.json")))
}

resource "tama_class" "introductory" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/introductory.json")))
}

resource "tama_class" "curse" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global]
  schema_json = jsonencode(jsondecode(file("${path.module}/basic/curse.json")))
}

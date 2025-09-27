resource "tama_space" "basic-conversation" {
  name = "Basic Conversation"
  type = "component"
}

resource "tama_class" "off-topic" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/off-topic.json")))
}

resource "tama_class" "greeting" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/greeting.json")))
}

resource "tama_class" "introductory" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/introductory.json")))
}

resource "tama_class" "curse" {
  space_id    = tama_space.basic-conversation.id
  depends_on  = [module.global.schemas]
  schema_json = jsonencode(jsondecode(file("basic/curse.json")))
}

resource "tama_class" "personalization" {
  space_id   = tama_space.basic-conversation.id
  depends_on = [module.global.schemas]

  schema {
    type  = "object"
    title = "personalization"

    description = file("basic/personalization.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

resource "tama_class" "patch" {
  space_id   = tama_space.basic-conversation.id
  depends_on = [module.global.schemas]
  schema {
    type  = "object"
    title = "patch"

    description = file("basic/patch.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

resource "tama_class" "manipulation" {
  space_id   = tama_space.basic-conversation.id
  depends_on = [module.global.schemas]
  schema {
    type  = "object"
    title = "manipulation"

    description = file("basic/manipulation.md")

    properties = jsonencode({
      origin_entity_id = {
        type        = "string"
        description = "The ID of the origin entity"
      }
    })
    required = ["origin_entity_id"]
  }
}

module "extract-embed-basic-conversation" {
  source  = "upmaru/base/tama//modules/extract-embed"
  version = "0.4.0"

  depends_on = [module.global.schemas]

  name      = "Extract and Embed User Messages"
  space_id  = tama_space.basic-conversation.id
  relations = ["content"]


  embeddable_class_ids = [
    tama_class.greeting.id,
    tama_class.introductory.id
  ]
}

resource "tama_space_bridge" "basic-conversation-memovee-ui" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = tama_space.ui.id
}

resource "tama_space_bridge" "basic-conversation-memovee" {
  space_id        = tama_space.basic-conversation.id
  target_space_id = module.memovee.space_id
}

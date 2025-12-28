//
// Scribe Queue
//

resource "tama_queue" "default" {
  role        = "scribe"
  name        = "default"
  concurrency = 2
}

resource "tama_queue" "branches" {
  role        = "scribe"
  name        = "branches"
  concurrency = 4
}

resource "tama_queue" "steps" {
  role        = "scribe"
  name        = "steps"
  concurrency = 4
}

resource "tama_queue" "flows" {
  role        = "scribe"
  name        = "flows"
  concurrency = 4
}

resource "tama_queue" "specifications" {
  role        = "scribe"
  name        = "specifications"
  concurrency = 2
}

resource "tama_queue" "agentic" {
  role        = "scribe"
  name        = "agentic"
  concurrency = 8
}

resource "tama_queue" "entities" {
  role        = "scribe"
  name        = "entities"
  concurrency = 4
}

resource "tama_queue" "concepts" {
  role        = "scribe"
  name        = "concepts"
  concurrency = 2
}

resource "tama_queue" "classes" {
  role        = "scribe"
  name        = "classes"
  concurrency = 1
}

resource "tama_queue" "actions" {
  role        = "scribe"
  name        = "actions"
  concurrency = 4
}

resource "tama_queue" "identities" {
  role        = "scribe"
  name        = "identities"
  concurrency = 2
}

//
// Oracle Queues
//

resource "tama_queue" "conversation" {
  role        = "oracle"
  name        = "conversation"
  concurrency = 48
}

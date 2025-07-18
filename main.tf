data "tama_space" "global" {
  id = "global"
}

resource "tama_space" "memovee" {
  name = "memovee"
  type = "root"
}

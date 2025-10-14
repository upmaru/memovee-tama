provider "tama" {}

module "global" {
  source  = "upmaru/base/tama"
  version = "0.4.3"
}

locals {
  tool_call_class = module.global.schemas.tool-call
}

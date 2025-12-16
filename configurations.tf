provider "tama" {
  timeout = 150
}

module "global" {
  source  = "upmaru/base/tama"
  version = "0.5.0"
}

locals {
  tool_call_class = module.global.schemas.tool-call
}

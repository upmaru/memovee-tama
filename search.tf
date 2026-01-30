module "memovee-search" {
  source  = "upmaru/base/tama//modules/messaging"
  version = "0.5.2"

  depends_on = [module.global.schemas]

  name = "Memovee Search"
}

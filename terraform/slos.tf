locals {
  slo_data = {
    for obj in flatten([for p in fileset(path.module, "../slos/**/*.yml") : yamldecode(file(p))])
    : "${obj.name} ${lookup(obj, "service", "default")} ${obj.environment}" => obj
  }
}

module "slo" {
  for_each = local.slo_data
  source   = "./modules/slo"

  name        = each.value.name
  environment = each.value.environment
  service     = lookup(each.value, "service", "")
  objectives  = each.value.objectives
}

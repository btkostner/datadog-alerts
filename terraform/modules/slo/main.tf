module "monitor" {
  for_each = { for idx, o in var.objectives : idx => o }
  source   = "../monitor"

  name           = each.value.name
  message        = each.value.message
  environment    = var.environment
  service        = var.service
  alert_channels = each.value.alert_channels
  type           = each.value.type
  method         = each.value.method
  path           = each.value.path
  priority       = each.value.priority
  percentile     = each.value.percentile
  custom_type    = each.value.custom_type
  custom_query   = each.value.custom_query
  critical       = each.value.critical
  warning        = each.value.warning
}

resource "time_sleep" "workaround" {
  create_duration = "4s"
  depends_on      = [datadog_service_level_objective.this]
}

resource "datadog_service_level_objective" "this" {
  name = var.name
  type = "monitor"
  # description = "My custom monitor SLO"
  monitor_ids = [for m in module.monitor : m.id]

  dynamic "thresholds" {
    for_each = var.thresholds

    content {
      target    = thresholds.value.target
      timeframe = thresholds.value.timeframe
      warning   = thresholds.value.warning
    }
  }

  force_delete = true

  tags = concat([
    "env:${var.environment}",
    "terraform:true"
    ],
    (var.service != "" ? ["service:${var.service}"] : [])
  )
}

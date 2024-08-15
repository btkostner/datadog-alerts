locals {
  names = {
    "custom"                     = var.name
    "error-tracking-trace-alert" = "[${var.environment}] ${var.service} new trace error 🐛"
    "error-tracking-log-alert"   = "[${var.environment}] ${var.service} new log error 🐛"
    "http-latency-max"           = "HTTP P${var.percentile} Latency for ${var.method} ${var.path}"
    "http-error-percentage"      = "HTTP Error Rate for ${var.method} ${var.path}"
  }
  messages = {
    "custom"                     = "Custom query has exceeded its critical threshold"
    "error-tracking-trace-alert" = <<EOT
{{#is_alert}}
[[ View In Error Tracking ](https://app.datadoghq.com/apm/error-tracking/issue/{{[@issue.id]}})] [[ View Trace ]({{span.link}})]

- Source: APM
- Service: {{span.service}}
- Environment: {{span.env}}
- Resource: {{span.resource_name}}
- Operation: {{span.operation_name}}

Message:
```
{{span.attributes.error.message}}
```
Stacktrace:
```
{{span.attributes.error.stack}}
```
{{/is_alert}}
{{#is_recovery}}
Issue has not occurred in 60m
{{/is_recovery}}
    EOT
    "error-tracking-log-alert"   = <<EOT
{{#is_alert}}
Datadog has tracked an error in {{span.service}}.

[View Log]({{log.link}})

- Source: Logs
- Service: {{log.service}}
- Environment: ${var.environment}

Message:
```
{{log.source}}
{{log.status}}
{{log.message}}
```
{{/is_alert}}
{{#is_recovery}}
Issue has not occurred in 60m
{{/is_recovery}}
    EOT
    "http-latency-max" = <<EOT
${var.percentile}th percentile HTTP latency for ${upper(var.method)} ${var.path} is over the acceptable ${var.critical}ms.

More information can be found on the [APM Page](https://app.datadoghq.com/apm/traces?query=${join("%20", [for k, v in {
    "@_top_level"  = 1
    env            = lower(var.environment)
    service        = var.service
    operation_name = "opentelemetry_phoenix.server"
    "@http.route"  = "\"${var.path}\""
    "@http.method" = upper(var.method)
    "@duration"    = ">=${var.warning}ms"
    } : urlencode("${k}:${v}")])}) and the [Logs Page](https://app.datadoghq.com/logs?query=${join("%20", [for k, v in {
    env            = lower(var.environment)
    service        = var.service
    "@http.method" = upper(var.method)
    "@duration"    = ">=${var.warning * 1000000}"
} : urlencode("${k}:${v}")])})
EOT
"http-error-percentage" = <<EOT
HTTP Error Rate for ${var.method} ${var.path} is over the acceptable ${var.critical}%.

More information can be found on the [APM Page](https://app.datadoghq.com/apm/traces?query=${join("%20", [for k, v in {
"@_top_level"       = 1
env                 = lower(var.environment)
service             = var.service
operation_name      = "opentelemetry_phoenix.server"
"@http.route"       = "\"${var.path}\""
"@http.method"      = upper(var.method)
"@http.status_code" = "5*"
} : urlencode("${k}:${v}")])}) and the [Logs Page](https://app.datadoghq.com/logs?query=${join("%20", [for k, v in {
env                 = lower(var.environment)
service             = var.service
"@http.method"      = upper(var.method)
"@http.status_code" = ">=500"
} : urlencode("${k}:${v}")])})
EOT
}
queries = {
  "custom"                     = var.custom_query
  "error-tracking-log-alert"   = "error-tracking-logs(\"env:${var.environment} service:${var.service} -@http.status_code:404\").rollup(\"count\").by(\"@issue.id\").last(\"60m\") >= ${var.critical}"
  "error-tracking-trace-alert" = "error-tracking-traces(\"env:${var.environment} service:${var.service} -@http.status_code:404\").rollup(\"count\").by(\"@issue.id\").last(\"60m\") >= ${var.critical}"
  "http-latency-max"           = "max(last_10m):default_zero(max:phoenix.router_dispatch.stop.duration.${var.percentile}percentile{env:${var.environment},service:${var.service},route:${var.path},method:${lower(var.method)}}) > ${var.critical}"
  "http-error-percentage"      = "max(last_5m):(default_zero(sum:phoenix.router_dispatch.stop.duration.count{env:${var.environment},service:${var.service},route:${var.path},method:${lower(var.method)},status:5*}.as_count())+default_zero(sum:phoenix.router_dispatch.exception.duration.count{env:${var.environment},service:${var.service},route:${var.path},method:${lower(var.method)},status:5*}.as_count()))/(default_zero(sum:phoenix.router_dispatch.stop.duration.count{env:${var.environment},service:${var.service},route:${var.path},method:${lower(var.method)}}.as_count())+default_zero(sum:phoenix.router_dispatch.exception.duration.count{env:${var.environment},service:${var.service},route:${var.path},method:${lower(var.method)}}.as_count())) >= ${var.critical}"
}
priorities = {
  "custom"                     = 4
  "error-tracking-log-alert"   = 3
  "error-tracking-trace-alert" = 3
  "http-latency-max"           = 3
  "http-error-percentage"      = 2
}
types = {
  "custom"                     = "query alert"
  "error-tracking-log-alert"   = "error-tracking alert"
  "error-tracking-trace-alert" = "error-tracking alert"
  "http-latency-max"           = "query alert"
  "http-error-percentage"      = "query alert"
}
renotify_intervals = {
  "custom"                     = 30
  "error-tracking-log-alert"   = 90
  "error-tracking-trace-alert" = 90
  "http-latency-max"           = 30
  "http-error-percentage"      = 30
}
extra_tags = {
  "custom"                     = ["sli:custom"]
  "error-tracking-log-alert"   = ["sli:error-tracking-logs"]
  "error-tracking-trace-alert" = ["sli:error-tracking-traces"]
  "http-latency-max"           = ["sli:latency", "method:${upper(var.method)}", "route:${lower(var.path)}"]
  "http-error-percentage"      = ["sli:error-rate", "method:${upper(var.method)}", "route:${lower(var.path)}"]
}
}

resource "time_sleep" "workaround" {
  create_duration = "4s"
  depends_on      = [datadog_monitor.this]
}

resource "datadog_monitor" "this" {
  name              = (var.name != null) ? var.name : local.names[var.type]
  type              = local.types[var.type]
  message           = join("\n\n", [trimspace((var.message != null) ? var.message : local.messages[var.type]), (var.alert_on_recovery != false) ? "{{#is_recovery}}${join(" ", var.alert_channels)}{{/is_recovery}}" : "", "{{#is_alert}} ${join(" ", var.alert_channels)} {{/is_alert}}"])
  priority          = (var.priority != null) ? var.priority : local.priorities[var.type]
  renotify_interval = (var.renotify_interval != null) ? var.renotify_interval : local.renotify_intervals[var.type]

  query = local.queries[var.type]

  monitor_thresholds {
    warning  = var.warning
    critical = var.critical
  }

  force_delete = true
  include_tags = false

  restricted_roles = []

  tags = concat([
    "env:${var.environment}",
    "terraform:true"
    ],
    local.extra_tags[var.type],
    (var.service != "" ? ["service:${var.service}"] : [])
  )
}

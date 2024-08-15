variable "name" {
  description = "Name of the monitor to create in Datadog. This is optional, and will be autogenerated if left empty and type, service, and environment are unique."
  type        = string
  nullable    = true
  default     = null
}

variable "message" {
  description = "A large text blob used when alerting. This is optional, and will use a standard, non descriptive, message if left empty. Note that if you just want to change who is alerted, you can do so by setting the alert_channels variable."
  type        = string
  nullable    = true
  default     = null
}

variable "environment" {
  description = "Environment this monitor is for. This should be staging or production."
  type        = string

  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be staging or production."
  }
}

variable "service" {
  description = "Name of the service this monitor is for. This is used to create the needed tags and link the monitor to the service's APM page."
  type        = string
  default     = ""
}

variable "alert_channels" {
  description = "A list of Datadog tags to include on the alert."
  type        = list(string)
  default     = []
}

variable "type" {
  description = "Type of resource that is being monitored, and how it's being monitored. For more details, look at the type documentation below."
  type        = string

  validation {
    condition     = contains(["custom", "http-latency-max", "http-error-percentage", "error-tracking-trace-alert", "error-tracking-log-alert"], var.type)
    error_message = "Monitor type must be one of (http-latency-max, http-error-percentage, error-tracking-trace-alert, error-tracking-log-alert)."
  }
}

variable "method" {
  description = "HTTP method being measured. This is only required for HTTP monitor types."
  type        = string
  default     = ""
}

variable "path" {
  description = "HTTP path being monitored. This is only required for HTTP monitor types."
  type        = string
  default     = ""
}

variable "priority" {
  description = "Priority of the monitor. By default, this will use the default priority assigned for the monitor type. Unless you have good reason to change the priority, we recommend leaving it generated."
  type        = number
  nullable    = true
  default     = null
}

variable "percentile" {
  description = "Percentile to use for the measurement. Valid values are 99, 95, 50, and 5."
  type        = number
  nullable    = false
  default     = 99
}

variable "custom_type" {
  description = "The custom type of monitor. This is only needed for custom monitor types. See https://docs.datadoghq.com/api/latest/monitors/#create-a-monitor for more information."
  type        = string
  default     = "metric alert"
}

variable "custom_query" {
  description = "The raw query used for monitoring when creating a custom monitor. This is different than the query you see in the UI depending on the custom_type. See https://docs.datadoghq.com/api/latest/monitors/#create-a-monitor for more information."
  type        = string
  nullable    = true
  default     = null
}

variable "critical" {
  description = "Measurement that triggers an error message. For more information about the unit this value is, look at the type documentation below."
  type        = number
}

variable "warning" {
  description = "Measurement that triggers a warning message. For more information about the unit this value is, look at the type documentation below."
  type        = number
}

variable "alert_on_recovery" {
  description = "Automatically send alerts to the listed alert_channels when a monitor recovers"
  type        = bool
  default     = true
}

variable "renotify_interval" {
  description = "The number of minutes after the last notification before the monitor re-notifies on the current status."
  type        = number
  nullable    = true
  default     = null
}

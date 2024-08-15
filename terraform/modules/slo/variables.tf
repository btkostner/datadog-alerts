variable "name" {
  description = "Name of the critical business operation. This should be human readable and understandable from a business perspective."
  type        = string
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

variable "objectives" {
  description = "A list of monitors to create that contribute to the SLO. For more information, see the monitors documentation."
  type = list(object({
    name           = optional(string)
    message        = optional(string)
    alert_channels = optional(list(string), [])
    type           = string
    method         = optional(string, "")
    path           = optional(string, "")
    priority       = optional(number)
    percentile     = optional(number)
    custom_type    = optional(string)
    custom_query   = optional(string)
    critical       = number
    warning        = number
  }))

  validation {
    condition     = length(var.objectives) >= 1
    error_message = "SLO must include at least 1 objective."
  }
}

variable "thresholds" {
  description = "Individual thresholds to check the SLO against. By default, we target 99.9% success for the past 30 days."
  type = list(object({
    target    = number
    timeframe = string
    warning   = number
  }))
  default = [{
    target    = 99.9
    timeframe = "30d"
    warning   = 99.95
  }]

  validation {
    condition     = length(var.thresholds) >= 1
    error_message = "SLO must include at least 1 threshold."
  }
}

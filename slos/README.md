# SLOs

This folder declares any SLOs and the monitors that power them. Any `.yml` file in this folder will be picked up by terraform.

## Structure

To define an SLO, include a block like so in the yaml file:

```yaml
- name: Dashboard View
  environment: production
  service: my-service
  objectives: []
```

The name should be the business context that is being measured. This should be human readable by non engineers. For instance, "GET /dashboard" would be a bad name, but "Dashboard View" tells exactly what it's monitoring. The environment should be "staging" or "production" depending what you want to measure. The service is the main service this SLO applies to.

The objectives are the different things we are measuring. These can only be applied to specific resource types. For instance, we can only measure latency for http resource types. Each of the objectives has a priority which defines how important that monitor is. It also includes a critical and warning field which define when we should alert. The unit for this measurement changes based on the resource type and objective type. For more information on the objectives, you can view the documentation in the [`monitors/`](../monitors) folder.

<!-- BEGIN_TF_DOCS -->

## Inputs

| Name        | Description                                                                                                                     | Type                                                                                                                                                                                                                                                                                                                                                                                                                | Default                                                                                        | Required |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | :------: |
| name        | Name of the critical business operation. This should be human readable and understandable from a business perspective.          | `string`                                                                                                                                                                                                                                                                                                                                                                                                            | n/a                                                                                            |   yes    |
| environment | Environment this monitor is for. This should be staging or production.                                                          | `string`                                                                                                                                                                                                                                                                                                                                                                                                            | n/a                                                                                            |   yes    |
| service     | Name of the service this monitor is for. This is used to create the needed tags and link the monitor to the service's APM page. | `string`                                                                                                                                                                                                                                                                                                                                                                                                            | `""`                                                                                           |    no    |
| objectives  | A list of monitors to create that contribute to the SLO. For more information, see the monitors documentation.                  | <pre>list(object({<br> name = optional(string)<br> message = optional(string)<br> alert_channels = optional(list(string), [])<br> type = string<br> method = optional(string, "")<br> path = optional(string, "")<br> priority = optional(number)<br> percentile = optional(number)<br> custom_type = optional(string)<br> custom_query = optional(string)<br> critical = number<br> warning = number<br> }))</pre> | n/a                                                                                            |   yes    |
| thresholds  | Individual thresholds to check the SLO against. By default, we target 99.9% success for the past 30 days.                       | <pre>list(object({<br> target = number<br> timeframe = string<br> warning = number<br> }))</pre>                                                                                                                                                                                                                                                                                                                    | <pre>[<br> {<br> "target": 99.9,<br> "timeframe": "30d",<br> "warning": 99.95<br> }<br>]</pre> |    no    |

<!-- END_TF_DOCS -->

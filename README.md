# Datadog Alerts

An example Terraform configuration to provision DataDog SLOs and monitors.

## SLO configuration

See the [`slos/`](./slos) directory for more information about creating and maintaining SLOs and monitors.

## Running

To run this terraform role, you will need to setup a Datadog API key and an App key. Once those are created, set them to `DD_API_KEY` and `DD_APP_KEY` environment variables respectively. Then you should be all set to run in the `terraform/` directory.

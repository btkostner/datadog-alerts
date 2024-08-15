terraform {
  backend "local" {}

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "datadog" {}

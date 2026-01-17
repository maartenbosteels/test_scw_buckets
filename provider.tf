terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.67.1"
    }
    grafana = {
      source = "grafana/grafana"
    }
  }
  required_version = ">= 0.13"
}

provider "scaleway" {
}
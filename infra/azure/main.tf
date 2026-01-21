terraform {
  required_version = "1.14.3"

  backend "s3" {
    region = "us-east-1"
    bucket = "personal-infra-states"
    key    = "portfolio/azure.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}
provider "azurerm" {
  subscription_id = var.subscription_id

  client_id    = var.azure_client_id
  client_secret = var.azure_client_secret
  features {}
}

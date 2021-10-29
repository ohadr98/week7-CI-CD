# Configure the Azure provider
terraform {
  required_version = ">= 0.14.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }    
  }
}

provider "azurerm" {
  features {}
}


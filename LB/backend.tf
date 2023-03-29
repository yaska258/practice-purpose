terraform {
  backend "azurerm" {
    resource_group_name  = "cloud-shell-storage-eastus"
    storage_account_name = "cs21003200285b71e6c"
    container_name       = "tfstate"
    key                  = "LB.terraform.tfstate"
  }
}
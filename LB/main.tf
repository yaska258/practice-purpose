resource "azurerm_resource_group" "azureproject_LB" {
  name     = "azureproject_LB-resources"
  location = "Central US"
}

resource "azurerm_public_ip" "azureproject" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.azureproject_LB.location
  resource_group_name = azurerm_resource_group.azureproject_LB.name
 allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}

resource "azurerm_lb" "azureproject" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.azureproject_LB.location
  resource_group_name = azurerm_resource_group.azureproject_LB.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.azureproject_LB.id
  }
}
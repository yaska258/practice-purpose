resource "azurerm_resource_group" "azureproject_SS" {
  name     = "azureproject-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "azureproject" {
  name                = "azureproject-network"
  resource_group_name = azurerm_resource_group.azureproject_SS.name
  location            = azurerm_resource_group.azureproject_SS.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.azureproject.name
  virtual_network_name = azurerm_virtual_network.azureproject.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "azureproject" {
  name                = "azureproject-vmss"
  resource_group_name = azurerm_resource_group.azureproject.name
  location            = azurerm_resource_group.azureproject.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "azureproject"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}




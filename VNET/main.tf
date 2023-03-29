resource "azurerm_resource_group" "azureproject_VNET" {
  name     = "azureproject_VNET-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "azureproject1" {
  name                = "azureproject-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azureproject1.location
  resource_group_name = azurerm_resource_group.azureproject1.name
}

resource "azurerm_subnet" "azureproject" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.azureproject_VNET.name
  virtual_network_name = azurerm_virtual_network.azureproject.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "azureproject" {
  name                = "azureproject-nic"
  location            = azurerm_resource_group.azureproject_VNET.location
  resource_group_name = azurerm_resource_group.azureproject_VNET.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azureproject.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "azureproject" {
  name                = "azureproject-machine"
  resource_group_name = azurerm_resource_group.azureproject_VNET.name
  location            = azurerm_resource_group.azureproject_VNET.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.azureproject.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
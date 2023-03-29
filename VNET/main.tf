resource "azurerm_resource_group" "azureproject_VNET" {
  name     = "azureproject_VNET-resources"
  location = "Central US"
}

resource "azurerm_virtual_network" "azureproject_VNET" {
  name                = "azureproject-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azureproject_VNET.location
  resource_group_name = azurerm_resource_group.azureproject_VNET.name
}

resource "azurerm_subnet" "azureproject" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.azureproject_VNET.name
  virtual_network_name = azurerm_virtual_network.azureproject_VNET.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "azureproject" {
  name                    = "azureproject-pip"
  location                = azurerm_resource_group.azureproject_VNET.location
  resource_group_name     = azurerm_resource_group.azureproject_VNET.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}



resource "azurerm_network_interface" "azureproject" {
  name                = "azureproject-nic"
  location            = azurerm_resource_group.azureproject_VNET.location
  resource_group_name = azurerm_resource_group.azureproject_VNET.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azureproject.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azureproject.id
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





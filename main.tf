provider "azurerm" 
{
    features{}
}
//Azure Resource group creation
resource "azurerm_resource_group" "devopstest"{
    name= "devopstest-rg"
    locaion= "centralindia"
}
//Azure Virtual Network configuration
resource "azurerm_virtual_network" "devopstest" {
  name                = "Devopstest-network"
  resource_group_name = azurerm_resource_group.devopstest.name
  location            = azurerm_resource_group.devopstest.location
  address_space       = ["10.0.0.0/16"]
}
//Azure two subnets in one vnet
resource "azurerm_subnet" "subnetwork" {
  name                 = "subnet1"
  virtual_network_name = azurerm_virtual_network.devopstest.name
  resource_group_name  = azurerm_resource_group.devopstest.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnetwork2" {
  name                 = "subnet2"
  virtual_network_name = azurerm_virtual_network.devopstest.name
  resource_group_name  = azurerm_resource_group.devopstest.name
  address_prefixes     = ["10.0.2.0/24"]
}

//Azure NSG and NSG rule

resource "azurerm_network_security_group" "devopstest" {
  name                = "test-nsg"
  resource_group_name = azurerm_resource_group.devopstest.name
  location            = azurerm_resource_group.devopstest.location
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.devopstest.name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "http"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_group" "devopstest" {
  name                = "test-nsg"
  resource_group_name = azurerm_resource_group.devopstest.name
  location            = azurerm_resource_group.devopstest.location
}

resource "azurerm_network_security_rule" "https" {
  name                        = "https"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.devopstest.name
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "http"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
// Getting the Azure Key vault secret

data "azurerm_key_vault" "devopstest" {
  name                = "kvname" // KeyVault name
  resource_group_name = "devops-rg" // resourceGroup
}

data "azurerm_key_vault_secret" "devopssecret" {
name = "kvsecret" // Name of secret
key_vault_id = data.azurerm_key_vault.devopstest.id
}

// zure Virtual Machine creation
resource "azurerm_network_interface" "devopstest" {
  name                = "devopstest1-nic"
  resource_group_name = azurerm_resource_group.devopstest.name
  location            = azurerm_resource_group.devopstest.location

  ip_configuration {
    name                          = "nic-ip"
    subnet_id                     = azurerm_subnet.subnetwork.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "devopstest" {
  name                            = "devopstest1-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = data.azurerm_key_vault_secret.devopssecret.value
  network_interface_ids = [
    azurerm_network_interface.devopstest.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_network_interface" "devopstest" {
  name                = "devopstest2-nic"
  resource_group_name = azurerm_resource_group.devopstest.name
  location            = azurerm_resource_group.devopstest.location

  ip_configuration {
    name                          = "nic-ip1"
    subnet_id                     = azurerm_subnet.subnetwork2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "devopstest" {
  name                            = "devopstest2-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = data.azurerm_key_vault_secret.devopssecret.value
  network_interface_ids = [
    azurerm_network_interface.devopstest.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}


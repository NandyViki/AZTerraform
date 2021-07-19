/* Azure as provider */
provider "azurerm" {
  features {}
  tenant_id       = "b9d2c79d-8655-430e-8cbb-d458178fd6b8"
  subscription_id = "3b415d59-619a-4a6f-8a0f-21eedfa275f3"
}

/* Create Resource Group */
resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-RG"
  location = var.location
}

/* Create Virtual Network */
resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}-VNET"
  address_space       = "${[var.vnetcidr]}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

/* Create Subnet part of the VNET */
resource "azurerm_subnet" "example" {
  name                 = "${var.prefix}-Subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = "${[var.subnetcidr]}"
}

/* Create NIC */

resource "azurerm_network_interface" "example" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  ip_configuration {
    name                          = "${var.prefix}-Subnet"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id // Link the pip created to the NIC
  }
}

/* Create Public IP */

resource "azurerm_public_ip" "example" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
}

/* Create Network Security Group */

resource "azurerm_network_security_group" "example" {
  name                = "${var.prefix}-NSG"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  // Repeat security_rule block for more rules to be configred 

}

/* Associate NSG with the NIC  */
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

/* Create VM */

resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.prefix}-VM"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = var.vmsize
  admin_username      = var.usrname
  admin_password      = var.passwd
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

}
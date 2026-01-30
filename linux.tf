resource "azurerm_network_security_group" "nsg1" {
  name                = "revisionnsg1"
  location            = azurerm_resource_group.revision3.location
  resource_group_name = azurerm_resource_group.revision3.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_virtual_network" "revisionvnet" {
  depends_on          = [azurerm_resource_group.revision3]
  name                = "revisionvnet1"
  location            = "central india"
  resource_group_name = "revision3rg"
  address_space       = ["10.0.0.0/16"]

}
resource "azurerm_subnet" "subnet1" {
  depends_on           = [azurerm_virtual_network.revisionvnet, azurerm_resource_group.revision3]
  name                 = "subnet11"
  resource_group_name  = "revision3rg"
  virtual_network_name = "revisionvnet1"
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_public_ip" "revisionpip" {
  depends_on          = [azurerm_resource_group.revision3]
  name                = "revisionpip1"
  resource_group_name = "revision3rg"
  location            = "central india"
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "revisionnic" {
  depends_on          = [azurerm_resource_group.revision3]
  name                = "revisionnic1"
  location            = "central india"
  resource_group_name = "revision3rg"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.revisionpip.id
  }
}

resource "azurerm_linux_virtual_machine" "revisionvm" {
  depends_on                      = [azurerm_resource_group.revision3]
  name                            = "revisionvm1"
  resource_group_name             = "revision3rg"
  location                        = "central india"
  size                            = "Standard_D2s_v5"
  admin_username                  = "adminuser"
  admin_password                  = "Password@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.revisionnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
resource "azurerm_storage_account" "revisionstg3" {
  depends_on               = [azurerm_resource_group.revision3]
  name                     = "revision3stg"
  resource_group_name      = "revision3rg"
  location                 = "central india"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
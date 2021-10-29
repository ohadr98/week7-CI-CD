terraform {
  required_version = ">= 0.14.9"
}

#Create a virtual machine(linux)
resource "azurerm_virtual_machine" "vm" {
  # count               = var.VM_COUNT //I tried to use it but could not figure out how it works.
  name                = var.VIRTUAL_MACHINE_NAME
  resource_group_name = var.RESOURCE_GROUP_NAME
  location            = var.AZURE_LOCATION
  availability_set_id = var.AVAILABILITY_SET_ID
  vm_size                = var.VM_SIZE
    network_interface_ids = [
    var.NETWORK_INTERFACE_IDS,
  ]

  storage_os_disk {
    name              = var.STORAGE_OS_DISK_NAME
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.VIRTUAL_MACHINE_NAME
    admin_username = var.STUDENT_NAME
    admin_password = var.VM_ADMIN_PASSWORD
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

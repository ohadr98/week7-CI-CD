# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.RESOURCE_GROUP_NAME
  location = var.AZURE_LOCATION
}

# Create a virtual network for the virtual machine
resource "azurerm_virtual_network" "terraform-vnet" {
  name                = "terraform-vnet"
  address_space       = [var.VNET_ADDRESS_SPACE]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet for the virtual machine
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.terraform-vnet.name
  address_prefixes     = [var.SUBNET_PUBLIC_ADDRESS_PREFIX]
}


# Create a public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "PublicIp"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"
}

resource "azurerm_public_ip" "publicipforvm1" {
    name                         = "PublicIpAppforvm1"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"
}

resource "azurerm_public_ip" "publicipforvm2" {
    name                         = "PublicIpAppforvm2"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Static"
}

#Create a network interface for public/app vm.
resource "azurerm_network_interface" "network_interface_public1" {
  name                = "nic_public1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public1"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicipforvm1.id
  }
}

#Create a network interface for public/app vm.
resource "azurerm_network_interface" "network_interface_public2" {
  name                = "nic_public2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public2"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicipforvm2.id

  }
}

#Create a Load Balancer
resource "azurerm_lb" "publicLB" {
  name                = "bootcamp-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "bootcamp-lb-publicIPAddress"
    public_ip_address_id = azurerm_public_ip.myterraformpublicip.id
  }
}

#Create a backend address pool for the load balancer
resource "azurerm_lb_backend_address_pool" "backend_address_pool_public" {
  loadbalancer_id = azurerm_lb.publicLB.id
  name            = "bootcamp-bap"
}

#Associate network interface1 to the load balancer backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_back_association" {
  network_interface_id    = azurerm_network_interface.network_interface_public1.id
  ip_configuration_name   = azurerm_network_interface.network_interface_public1.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}

#Associate network interface2 to the load balancer backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "nic2_back_association" {
  network_interface_id    = azurerm_network_interface.network_interface_public2.id
  ip_configuration_name   = azurerm_network_interface.network_interface_public2.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_public.id
}

#Create load balancer probe for port 8080
resource "azurerm_lb_probe" "lb_probe" {
  name                = "bootcamp-lbtcpProbe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.publicLB.id
  protocol            = "HTTP"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
  request_path        = "/"

}

#Create load balancer rule for port 8080
resource "azurerm_lb_rule" "bootcamp_Week5-LB_rule8080" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.publicLB.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.publicLB.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.lb_probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool_public.id  
}

#Create public availability set
resource "azurerm_availability_set" "availability_set1" {
  name                = "bootcamp-Aset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#Create a network_security_group for public subnet 
resource "azurerm_network_security_group" "nsg_public" {
  name                = "nsg_public"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

 security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.YOUR_COMPUTER_ADDRESS_PREFIX
    destination_address_prefix = var.YOUR_COMPUTER_ADDRESS_PREFIX
  }
  security_rule {
    name                       = "Port_8080"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "Production"
  }
}

# #Create  association between nsg and sbnet (public)
  resource "azurerm_subnet_network_security_group_association" "association_public" {
   subnet_id                 = azurerm_subnet.public.id
    network_security_group_id = azurerm_network_security_group.nsg_public.id
 }

#Associate network interface1 to public subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.network_interface_public1.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

#Associate network interface2 to public subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "nsg_nic2" {
  network_interface_id      = azurerm_network_interface.network_interface_public2.id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}

module "vm1" {
  source                = "../modules/virtualmachine"

  VIRTUAL_MACHINE_NAME  = "bootcampAppVMApp1"
  RESOURCE_GROUP_NAME   = azurerm_resource_group.rg.name
  AZURE_LOCATION        = azurerm_resource_group.rg.location
  AVAILABILITY_SET_ID   = azurerm_availability_set.availability_set1.id
  STUDENT_NAME          = "Ohad"
  VM_SIZE               = "Standard_B1s"
  NETWORK_INTERFACE_IDS = azurerm_network_interface.network_interface_public1.id
  STORAGE_OS_DISK_NAME  = "bootcamp-storage-os-disk1"
  VM_ADMIN_PASSWORD     = var.VM_ADMIN_PASSWORD
}

module "vm2" {
  source                = "../modules/virtualmachine"

  VIRTUAL_MACHINE_NAME  = "bootcampAppVMApp2"
  RESOURCE_GROUP_NAME   = azurerm_resource_group.rg.name
  AZURE_LOCATION        = azurerm_resource_group.rg.location
  AVAILABILITY_SET_ID   = azurerm_availability_set.availability_set1.id
  STUDENT_NAME          = "Ohad"
  VM_SIZE               = "Standard_B1s"
  NETWORK_INTERFACE_IDS = azurerm_network_interface.network_interface_public2.id
  STORAGE_OS_DISK_NAME  = "bootcamp-storage-os-disk2"
  VM_ADMIN_PASSWORD     = var.VM_ADMIN_PASSWORD
}

#Get ip data for postgres
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.myterraformpublicip.name
  resource_group_name = var.RESOURCE_GROUP_NAME


}


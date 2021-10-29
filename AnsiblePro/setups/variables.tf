variable "RESOURCE_GROUP_NAME" {
  type        = string
  description = "The Name that will be used to set the resources names"
}

variable "STUDENT_NAME" {
  type        = string
  description = "The Name that will be used to set the student names"
}

variable "AZURE_LOCATION" {
  type        = string
  description = "The Azure location where the resources exists"
}

variable "VNET_ADDRESS_SPACE" {
  type        = string
  description = "The cidr used for the virtual network"
}

variable "SUBNET_PRIVATE_ADDRESS_PREFIX" {
  type        = string
  description = "The cidr used for the subnet"
}

variable "SUBNET_PUBLIC_ADDRESS_PREFIX" {
  type        = string
  description = "The cidr used for the subnet"
}

variable "YOUR_COMPUTER_ADDRESS_PREFIX" {
  type        = string
  description = "The cidr used for the subnet"
}

variable "VM_ADMIN_PASSWORD" {
  type        = string
  description = "The password uses to access the VM"
}

variable "VM_ADMIN_PASSWORD_DB" {
  type        = string
  description = "The password uses to access the VM"
}
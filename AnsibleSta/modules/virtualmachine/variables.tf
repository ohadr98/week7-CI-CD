
variable "VIRTUAL_MACHINE_NAME" {
  type        = string
  description = "The Name that will be used to set the virtual machine"
}

variable "RESOURCE_GROUP_NAME" {
  type        = string
  description = "The Name that will be used to set the resources names"
}

variable "AZURE_LOCATION" {
  type        = string
  description = "The Azure location where the resources exists"
}

variable "AVAILABILITY_SET_ID" {
  type        = string
  description = "id of AVAILABILITY_SET you want to use."
}

variable "STUDENT_NAME" {
  type        = string
  description = "The Name that will be used to set the student names"
}

variable "VM_SIZE" {
  type        = string
  description = "The size of the virtual machine you want to create."
}

variable "NETWORK_INTERFACE_IDS" {
  type        = string
  description = "The id of the virtual machine network_interface you want to create."
}

variable "STORAGE_OS_DISK_NAME" {
  type        = string
  description = "The Name Of STORAGE_OS_DISK"
}

variable "VM_ADMIN_PASSWORD" {
  type        = string
  description = "The password uses to access the VM"
}


variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2s"
}

variable "os_type" {
  description = "Operating system type (linux or windows)"
  type        = string
  default     = "linux"
}

variable "os_disk_type" {
  description = "Type of OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "enable_public_ip" {
  description = "Whether to create a public IP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

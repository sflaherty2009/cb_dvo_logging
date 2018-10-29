variable "subscription_id" {
  default =  "9db13c96-62ad-4945-9579-74aeed296e48"
}

variable "location" {
  description = "The default Azure region for the resource provisioning"
  default     = "East US 2"
}

variable "lin_image_publisher" {
  description = "Publisher name of the linux machine image"
  default     = "OpenLogic"
}

variable "lin_image_offer" {
  description = "Offer name of the linux machine image"
  default     = "CentOS"
}

variable "lin_image_sku" {
  description = "SKU of the linux machine image"
  default     = "7.4"
}

variable "lin_image_version" {
  description = "Image version desired for linux machines"
  default     = "7.4.20180118"
}

variable "vnet" {
  description = "Name of the virtual network to be used."
  default = "AZ-VN-EastUS2-01"
}

variable "vm_name" {
    description = "Name of the VM used."
    default = "azl-chef-deli"
}
variable "vm_size" {
  description = "Desired size of the node"
  default     = "Standard_DS1_v2"
}

variable "count_vms" {
  description = "Number of desired vms"
  default     = 1
}

variable "subnet_id" {
  description = "Full path of the subnet desired for the node"
  default = "/subscriptions/9db13c96-62ad-4945-9579-74aeed296e48/resourceGroups/AZ-RG-Network/providers/Microsoft.Network/virtualNetworks/AZ-VN-EastUS2-01/subnets/AZ-SN-back"
}

variable "cookbook_name" {}
variable "admin_user" {}
variable "admin_password" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "resource_group_name" {
  description = "Name of the resource group for the hub network"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the hub virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "DNS servers to use for the hub virtual network"
  type        = list(string)
  default     = []
}

variable "firewall_subnet_address_prefix" {
  description = "Address prefix for the firewall subnet"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "gateway_subnet_address_prefix" {
  description = "Address prefix for the gateway subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "bastion_subnet_address_prefix" {
  description = "Address prefix for the bastion subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the resource group for the spoke network"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vnet_name" {
  description = "Name of the spoke virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the spoke virtual network"
  type        = list(string)
}

variable "dns_servers" {
  description = "DNS servers to use for the spoke virtual network"
  type        = list(string)
  default     = []
}

variable "aks_subnet_name" {
  description = "Name of the AKS subnet"
  type        = string
  default     = "aks-subnet"
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix for the AKS subnet"
  type        = list(string)
}

variable "aks_subnet_service_endpoints" {
  description = "Service endpoints for the AKS subnet"
  type        = list(string)
  default     = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}

variable "aks_subnet_delegations" {
  description = "Delegations for the AKS subnet"
  type = list(object({
    name         = string
    service_name = string
    actions      = list(string)
  }))
  default = []
}

variable "additional_subnets" {
  description = "Additional subnets to create in the spoke network"
  type = map(object({
    address_prefixes   = list(string)
    service_endpoints  = optional(list(string), [])
    delegations = optional(list(object({
      name         = string
      service_name = string
      actions      = list(string)
    })), [])
  }))
  default = {}
}

variable "hub_virtual_network_id" {
  description = "ID of the hub virtual network"
  type        = string
}

variable "hub_virtual_network_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Name of the hub resource group"
  type        = string
}

variable "hub_firewall_private_ip" {
  description = "Private IP of the hub firewall"
  type        = string
}

variable "use_remote_gateways" {
  description = "Option to use remote gateways from the hub network"
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Option to allow gateway transit from the hub network"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "The Subscription ID where the resources will be created."
  type        = string
  sensitive  = true
}

variable "vmss_password" {
  description = "The admin password for the VMSS instances."
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "The client ID for the Azure Service Principal."
  type        = string
}

variable "azure_client_secret" {
  description = "The client secret for the Azure Service Principal."
  type        = string
  sensitive   = true
}

####Credentials###

variable "INSERT_DELEGATED_ACCOUNT_ID" {
  type = string
}

variable "INSERT_ASSUME_ROLE_NAME" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
}

variable "public_subnets_cidr" {
  type        = list(string)
  default     = []
}

variable "private_subnets_cidr" {
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}
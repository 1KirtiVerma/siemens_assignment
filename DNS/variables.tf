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

variable "lb_name" {
  type = string
}

variable "zone_id" {
  description = "ID of DNS zone"
  type        = string
  default     = null
}

variable "zone_name" {
  description = "Name of DNS zone"
  type        = string
  default     = null
}

variable "private_zone" {
  description = "Whether Route53 zone is private or public"
  type        = bool
  default     = false
}

variable "dns_name" {
  type = string
}

variable "type" {
  type = string
}
variable "domain_name" {
  description = "Private Hosted zone name of the Route53 entry"
}

variable "route_names" {
  description = "DNS names to be created"
}

variable "private_zone" {
  description = "True if the the hosted zone is private"
  default     = true
  type = bool
}

variable "record_type" {
  description = "Type of record in route53"
  type        = string
  default     = "CNAME"
}

variable "ttl" {
  description = "Time to live"
  type = number
  default     = 300
}

variable "records" {
  description = "List of records"
  type        = list
}

variable "create_record" {
  description = "Flag to enable/disable r53-private-zone-create record"
  default     = true
  type = bool
}

#domain
variable "domain" {
  type        = string
  description = "The domain name of the site"
}

#subject_alternative_names
variable "subject_alternative_names" {
  type        = list(string)
  description = "A list of domains that should be SANs in the issued certificate"
  default     = []
}
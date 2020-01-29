
#################################################################
# VARIABLES
#################################################################

variable "ingress_domain" {}

variable "saml_profile" {
  default = "natalie.chin"
  type    = string
}

variable "region" {
  default = "ap-southeast-1"
  type    = string
}

variable "security_group_id" {}

variable "cluster-name" {
  default = "infra101-week7"
  type    = string
}

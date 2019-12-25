variable "tags" {}
variable "generictag" {}
variable "projectname" {}
variable "env" {}
variable "domain_name" {}
variable "acm_creation" {
  description = "Whether to create the IAM user"
  type        = bool
}
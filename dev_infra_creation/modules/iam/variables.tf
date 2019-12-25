variable "region" {}
variable "projectname" {}
variable "env" {}
variable "tags" {}
variable "dr_velero_backup_bucket" {}
variable "iam_create_user" {
  description = "Whether to create the IAM user"
  type        = bool
}

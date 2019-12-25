output "bastion_role" {
value = "${aws_iam_role.bastion_role.name}"
}

output "bastion_role_arn" {
value = "${aws_iam_role.bastion_role.arn}"
}
output "bastion_instance_profile_role" {
value = "${aws_iam_instance_profile.ec2_profile.name}"
}

output "app01_user_keys" {
  description = "The access key ID"
  value       = element(concat(aws_iam_access_key.app01_user_keys.*.id, [""]), 0)
}

output "app01_user_access_key_secret" {
  description = "The access key secret"
  value       = element(concat(aws_iam_access_key.app01_user_keys.*.secret, [""]), 0)
}


output "app02_user_access_key" {
  description = "The access key ID"
  value       = element(concat(aws_iam_access_key.app02_user_access_keys.*.id, [""]), 0)
}

output "app02_user_access_key_secret" {
  description = "The access key secret"
  value       = element(concat(aws_iam_access_key.app02_user_access_keys.*.secret, [""]), 0)
}

output "app03_user_access_key" {
  description = "The access key ID"
  value       = element(concat(aws_iam_access_key.app03_user_access_keys.*.id, [""]), 0)
}

output "app03_user_access_key_secret" {
  description = "The access key secret"
  value       = element(concat(aws_iam_access_key.app03_user_access_keys.*.secret, [""]), 0)
}

output "velero_user_access_key" {
  description = "The access key ID"
  value       = element(concat(aws_iam_access_key.velero_user_access_keys.*.id, [""]), 0)
}

output "velero_user_access_key_secret" {
  description = "The access key secret"
  value       = element(concat(aws_iam_access_key.velero_user_access_keys.*.secret, [""]), 0)
}



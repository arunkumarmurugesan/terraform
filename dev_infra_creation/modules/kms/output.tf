output "rds_kms_arn" {
    value = "${data.aws_kms_alias.rds_key.arn}"
}

output "es_kms_arn" {
    value = "${data.aws_kms_alias.es_key.arn}"
}

output "app01_kms_arn" {
    value = "${aws_kms_key.ntnx_cloudmgnt.arn}"
}

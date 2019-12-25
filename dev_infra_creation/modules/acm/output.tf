output "iot_cert" {
value       = element(concat(aws_acm_certificate.cert.*.arn, [""]), 0)
}

output "example_cert" {
value       = element(concat(aws_acm_certificate.example.*.arn, [""]), 0)
}


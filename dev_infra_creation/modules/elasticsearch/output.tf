output "es_arn" {
    #value = "${aws_elasticsearch_domain.es.arn}"
    value       = element(concat(aws_elasticsearch_domain.es.*.arn, [""]), 0)
}
output "es_domain_id" {
    #value = "${aws_elasticsearch_domain.es.domain_id}"
    value       = element(concat(aws_elasticsearch_domain.es.*.domain_id, [""]), 0)
}
output "es_endpoint" {
    #value = "${aws_elasticsearch_domain.es.endpoint}"
    value      = element(concat(aws_elasticsearch_domain.es.*.endpoint, [""]), 0)
}
output "es_kibana_endpoint" {
    #value = "${aws_elasticsearch_domain.es.kibana_endpoint}"
    value      = element(concat(aws_elasticsearch_domain.es.*.kibana_endpoint, [""]), 0)
}

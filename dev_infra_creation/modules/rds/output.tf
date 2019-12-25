output "db_cluster_address" {
    #value = "${aws_rds_cluster.aurora_cluster.cluster_identifier}"
    value       = element(concat(aws_rds_cluster.aurora_cluster.*.cluster_identifier, [""]), 0)
}

output "db_cluster_master_writer_endpoint" {
    #value = "${aws_rds_cluster.aurora_cluster.endpoint}"
    value       = element(concat(aws_rds_cluster.aurora_cluster.*.endpoint, [""]), 0)
}

output "db_cluster_master_reader_endpoint" {
    #value = "${aws_rds_cluster.aurora_cluster.reader_endpoint}"
    value       = element(concat(aws_rds_cluster.aurora_cluster.*.reader_endpoint, [""]), 0)
}


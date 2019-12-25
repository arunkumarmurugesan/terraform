data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "es" {
    count = var.es_creation ? 1 : 0
    lifecycle {
            create_before_destroy = "true"
            ignore_changes  = ["access_policies"]
    }

    domain_name           = "${var.projectname}-${var.env}-edge"
    elasticsearch_version = "${var.es_version}"
    cluster_config {
    instance_type       = "${var.es_instance_type}"
    instance_count      = "${var.es_instance_count}"
    zone_awareness_enabled  = "${var.es_zone_awareness}"
    zone_awareness_config {
        availability_zone_count = "${var.es_instance_count}"
    }
  }
    node_to_node_encryption {
      enabled = true
  }

    ebs_options {
      ebs_enabled = "${var.es_ebs_volume_size > 0 ? true : false}"
      volume_size = "${var.es_ebs_volume_size}"
      volume_type = "gp2"
  }
    encrypt_at_rest {
      enabled = true
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
 
  snapshot_options {
    automated_snapshot_start_hour = 23
  }

tags = "${merge(var.tags,map("Name", "${var.projectname}-${var.env}-edge"))}"

}


resource "aws_elasticsearch_domain_policy" "main" {
    count = var.es_creation ? 1 : 0
    domain_name = "${aws_elasticsearch_domain.es[0].domain_name}"
    access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.projectname}-${var.env}-edge/*",
            "Condition": {
               "IpAddress": {"aws:SourceIp": ["127.0.0.1/32", "127.0.0.1/32"]}
            }
        }
    ]
}
POLICIES
}


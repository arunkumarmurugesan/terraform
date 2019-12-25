########################
## Cluster
########################

# Declare the data source
#data "aws_availability_zones" "available" {}
#data "aws_kms_alias" "key" { 
#    name = "alias/aws/rds" 
#}

resource "aws_rds_cluster" "aurora_cluster" {
    lifecycle {
            create_before_destroy = true
    }
    count = var.rds_creation ? 1 : 0
    cluster_identifier            = "${var.projectname}-${var.env}-pg-cluster"
    database_name                 = "${var.rds_database_name}"
    engine                        = "aurora-postgresql"
    engine_version                = "${var.rds_engine_version}"
    master_username               = "${var.rds_master_username}"
    master_password               = "${var.rds_master_password}"
    backup_retention_period       = 14
    preferred_backup_window       = "02:00-03:00"
    preferred_maintenance_window  = "sat:07:24-sat:07:54"
    db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group[0].name}"
    #availability_zones            = [ "${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
    #availability_zones            = "${var.local}"
    final_snapshot_identifier     = "${var.env}-aurora-cluster-${uuid()}"
    port                          = "${var.rds_port}"
    storage_encrypted             = true
    vpc_security_group_ids        = "${var.rds_security_group_id}" 
    deletion_protection           = true
    tags                          = "${merge(var.tags,map("Name", "${var.projectname}-${var.env}-AuroraPostgres-DB-Cluster"))}"
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
    lifecycle {
            create_before_destroy = true
    }
    depends_on = [aws_rds_cluster.aurora_cluster] 
    count                           = 2
    identifier                      = "${var.projectname}-${var.env}-aurora-instance-${count.index}"
    cluster_identifier              = "${aws_rds_cluster.aurora_cluster[0].id}"
    instance_class                  = "${var.rds_instance_class}"
    db_subnet_group_name            = "${aws_db_subnet_group.aurora_subnet_group[0].name}"
    publicly_accessible             = false
    promotion_tier	                = "1"
    engine                          = "aurora-postgresql"
    engine_version                  = "${var.rds_engine_version}"
    performance_insights_enabled    = true 
    #performance_insights_kms_key_id = "${data.aws_kms_alias.key.arn}"
    #performance_insights_kms_key_id = "${var.rds_kms}"
    tags   = "${merge(var.tags,map("Name", "${var.projectname}-${var.env}-AuroraPostgres-DB-Instance-${count.index}"))}"

}

resource "aws_db_subnet_group" "aurora_subnet_group" {
    lifecycle {
            create_before_destroy = true
    }
    count = var.rds_creation ? 1 : 0
    name          = "${var.env}_aurora_db_subnet_group"
    description   = "Allowed subnets for Aurora DB cluster instances"
    subnet_ids    = [ "${var.private_subnet_ids[0]}","${var.private_subnet_ids[1]}","${var.private_subnet_ids[2]}" ]

    tags = {
        Name         = "${var.env}-Aurora-DB-Subnet-Group"
        ManagedBy    = "terraform"
        Environment  = "${var.env}"
    }
}



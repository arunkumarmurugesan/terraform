variable "generictag" {}
variable "region" {}
variable "domain_name" {}
variable "office_ips" { type = list }
variable "env" {}
variable "prod_vpc_cidr_id" {}
variable "ops_vpc_cidr_id" {}
variable "ami_id" {}
variable "instance_type" {}
variable "projectname" {}
variable "azs" {
type = map
    default = {
        "eu-west-1"      = "eu-west-1a,eu-west-1b,eu-west-1c"
        "eu-west-2"      = "eu-west-2a,eu-west-2b,eu-west-2c"
        "us-west-1"      = "us-west-1a,us-west-1b,us-west-1c"
        "us-west-2"      = "us-west-2a,us-west-2b,us-west-2c"
        "us-east-2"      = "us-east-2a,us-east-2b,us-east-2c"
        "us-east-1"      = "us-east-1a,us-east-1b,us-east-1c"
        "eu-west-3"      = "eu-west-3a,eu-west-3b,eu-west-3c"
        "eu-central-1"   = "eu-central-1a,eu-central-1b,eu-central-1c"
        "eu-north-1"     = "eu-north-1a,eu-north-1b,eu-north-1c"
#        "sa-east-1"      = "sa-east-1a,sa-east-1b,sa-east-1c"
#        "cn-north-1"     = "cn-north-1a,cn-north-1b"
#        "cn-northwest-1" = "cn-northwest-1a,cn-northwest-1b,cn-northwest-1c"
#        "ca-central-1"   = "ca-central-1a,ca-central-1b"
        "ap-northeast-1" = "ap-northeast-1a,ap-northeast-1b,ap-northeast-1c"
        "ap-northeast-2" = "ap-northeast-2a,ap-northeast-2b"
        "ap-southeast-2" = "ap-southeast-2a,ap-southeast-2b,ap-southeast-2c"
        "ap-southeast-1" = "ap-southeast-1a,ap-southeast-1b,ap-southeast-1c"
        "ap-south-1"     = "ap-south-1a,ap-south-1b"
        "me-south-1"     = "me-south-1a,me-south-1b,me-south-1c"
    }
}

variable "ops_vpc_range"  {
default = {
    cidr_block           = "10.99.0.0/16"
    subnet_bits          = "6"
    }
}
variable "prod_vpc_range"  {
default = {
    cidr_block           = "10.89.0.0/16"
    subnet_bits          = "6"
    }
}
variable "rds_master_username" {}
variable "rds_master_password" {}
variable "rds_database_name" {}
variable "rds_engine_version" {}
variable "rds_port" {}
variable "rds_instance_class" {}
variable "es_version" {}
variable "es_instance_type" {}
variable "es_instance_count" {}
variable "es_ebs_volume_size" {}
variable "es_zone_awareness" {}
variable "ec2_public_key" {}
variable "cluster_name" {}
variable "iam_create_user" {}
variable "acm_creation" {}
variable "es_creation" {}
variable "rds_creation" {}
variable "master_instance" {} 
variable "node_instance" {}  
variable "kube_version" {}
variable "rl_node_instance" {}
variable "dr_es_backup_bucket" {}
variable "dr_velero_backup_bucket" {}
variable "dr_bundlelog_backup_bucket" {}
variable "dr_release_backup_bucket" {}
variable "dr_ml_backup_bucket" {}
variable "dr_jwt_token" {}
variable "dr_app_kms" {}
variable "dr_release_prefix_backup_bucket" {}
variable "dr_db_name" {}
variable "dr_namespaces" {}

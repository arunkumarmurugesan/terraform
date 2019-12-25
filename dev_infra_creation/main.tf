locals {
  owner             = "Ops"
  Infra             = "${var.projectname}"
  Environment       = "${var.env}"
  Terraformed       = "true"
  KubernetesCluster = "${var.env}.${var.cluster_name}"
}

locals {
   #Common tags to be assigned to all resources
  common_tags = {
    Owner               = local.owner
    Infra               = local.Infra
    Environment         = local.Environment
    Terraformed         = local.Terraformed
    KubernetesCluster   = local.KubernetesCluster
  }
}

module "ops_vpc" {
  source                = "./modules/ops_vpc"
  env                   = "${var.env}"
  ops_vpc_range         = "${var.ops_vpc_range}"
  projectname           = "${var.projectname}"
  generictag            = "${var.generictag}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  azs                   = "${var.azs}"
}

module "prod_vpc" {
  source                = "./modules/prod_vpc"
  env                   = "${var.env}"
  prod_vpc_range         = "${var.prod_vpc_range}"
  projectname           = "${var.projectname}"
  generictag            = "${var.generictag}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  azs                   = "${var.azs}"
}

module "vpcpeer" {
  source                = "./modules/vpcpeer"
  owner_vpc             = "${module.ops_vpc.vpcid}"
  peer_vpc              = "${module.prod_vpc.vpcid}"
  ops_vpc_range         = "${var.ops_vpc_range}"
  prod_vpc_range        = "${var.prod_vpc_range}"
  prod_route_table_public  = "${module.prod_vpc.prod_route_table_public}" 
  prod_route_table_private = "${module.prod_vpc.prod_route_table_private}"
  ops_route_table_public   = "${module.ops_vpc.ops_route_table_public}"
  ops_route_table_private  = "${module.ops_vpc.ops_route_table_private}"
  projectname           = "${var.projectname}"
  generictag            = "${var.generictag}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  azs                   = "${var.azs}"
  env                   = "${var.env}"
}

module "sg" {
  source                = "./modules/sg"
  projectname           = "${var.projectname}"
  tags                  = "${local.common_tags}"
  env                   = "${var.env}"
  office_ips            = "${var.office_ips}"
  prod_vpc_range        = "${var.prod_vpc_cidr_id}"
  ops_vpc               = "${module.ops_vpc.vpcid}"
  prod_vpc              = "${module.prod_vpc.vpcid}"
}

module "rds" {
  source                = "./modules/rds"
  projectname           = "${var.projectname}"
  generictag            = "${var.generictag}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  azs                   = "${var.azs}"
  env                   = "${var.env}"
  rds_master_username   = "${var.rds_master_username}"
  rds_master_password   = "${var.rds_master_password}"
  rds_database_name     = "${var.rds_database_name}"
  rds_engine_version    = "${var.rds_engine_version}"
  rds_port              = "${var.rds_port}"
  rds_instance_class    = "${var.rds_instance_class}"
  rds_security_group_id = "${module.sg.rds_security_group_id}"
  bastion_security_group_id = "${module.sg.bastion_security_group_id}"
  private_subnet_ids        = "${module.prod_vpc.private_subnet_ids}"
  rds_creation          = "${var.rds_creation}"
}

module "elasticsearch" {
  source                = "./modules/elasticsearch"
  projectname           = "${var.projectname}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  env                   = "${var.env}"
  office_ips            = "${var.office_ips}"
  es_version            = "${var.es_version}"
  es_instance_type      = "${var.es_instance_type}"
  es_ebs_volume_size    = "${var.es_ebs_volume_size}"
  es_instance_count     = "${var.es_instance_count}"
  es_zone_awareness     = "${var.es_zone_awareness}"
  es_creation           = "${var.es_creation}"
}

module "acm" {
  source                = "./modules/acm"
  projectname           = "${var.projectname}"
  generictag            = "${var.generictag}"
  tags                  = "${local.common_tags}"
  env                   = "${var.env}"
  domain_name           = "${var.domain_name}"
  acm_creation          = "${var.acm_creation}"
}

#module "ssh" {
#  source                = "./modules/ssh_key"
#  ssh_gen               = "${var.ssh_gen}"
#}

module "ec2" {
  source                = "./modules/ec2"
  projectname           = "${var.projectname}"
  generictag            = "${var.generictag}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  env                   = "${var.env}"
  ops_vpc               = "${module.ops_vpc.vpcid}"
  instance_type         = "${var.instance_type}"
  sg_id                 = "${module.sg.bastion_security_group_id}"
  ami_id                = "${var.ami_id}"
  subnet_id             = "${module.ops_vpc.subnet_id}"
  iam_role              = "${module.iam.bastion_instance_profile_role}"
  #ssh_gen               = "${var.ssh_gen}"
}

module "iam" {
  source                = "./modules/iam"
  projectname           = "${var.projectname}"
  tags                  = "${local.common_tags}"
  region                = "${var.region}"
  env                   = "${var.env}"
  iam_create_user       = "${var.iam_create_user}"
  dr_velero_backup_bucket = "${var.dr_velero_backup_bucket}"
}

module "kms" {
  source                = "./modules/kms"
  projectname           = "${var.projectname}"
  tags                  = "${local.common_tags}"
}

module "privatedns" {
  source                = "./modules/privatedns"
  projectname           = "${var.projectname}"
  tags                  = "${local.common_tags}"
  env                   = "${var.env}"
  cluster_name          = "${var.cluster_name}"
  prod_vpc              = "${module.prod_vpc.vpcid}"
}

module "s3" {
  source                = "./modules/s3"
  projectname           = "${var.projectname}"
  tags                  = "${local.common_tags}"
  env                   = "${var.env}"
  region                = "${var.region}"
}

region              = "eu-central-1"
domain_name         = "example.com"
cluster_name        = "example.com"
office_ips          = ["127.0.0.1/32" "127.0.0.1/32" "127.0.0.1/32"]
instance_type       = "t2.medium"
ami_id              = "ami-xxxxx"
generictag          = "test-ops"
#keyname            = "bastion-key"
env                 = "test"
prod_vpc_cidr_id    = "10.89.0.0/16"
ops_vpc_cidr_id     = "10.99.0.0/16"
projectname         = "project-test"

#RDS variables
rds_master_username = "root"
rds_master_password = "dummypassword"
rds_database_name   = "test"
rds_engine_version  = "10.7"
rds_port            = "7587"
rds_instance_class  = "db.r4.large"

#ES variables
es_version          = "7.1"
es_instance_type    = "m4.large.elasticsearch"
es_instance_count   = "2"
es_ebs_volume_size  = "250"
es_zone_awareness   = "true"

#Kops Cluster variables
master_instance     = "m5.large"
node_instance       = "m5.xlarge"
kube_version        = "1.15.6"
rl_node_instance    = "m5.2xlarge"

#EC2 Public Key     
ec2_public_key = "ssh-rsa xxxxxxxxxxxxxx+xxxxxxx"



# Condition for creation - default is false
rds_creation        = true 
es_creation         = true
iam_create_user     = true
acm_creation        = true

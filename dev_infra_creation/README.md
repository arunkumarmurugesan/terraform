Introduction: 
This document provides prescriptive guidance for bringing up the dev aws infrastructure and kubernetes cluster 

Execution: 

To set up the fresh infrastructure follows the below workflow to create the infra

Execution: 

Execution of the Fresh Infrastructure
./init.sh --action init --env test --restoration no

1. Begin with creation of infrastructures such as RDS, ES, S3, VPC, and PrivateHostedZone
2. Creates the kubernetes cluster with three Master and Six Worker nodes ( Three work nodes for app01 Service and another app02 )

Prerequisites : 

Install/Import Packages mentioned below:
1.Python3
2.pip
3.boto3
4.time
5.datetime
6.argparse
7.logging
8.paramiko
9.tarfile
10.requests
11.requests_aws4auth
12.pathlib
13.terraform
14.jq
15.kops
16.kubelet

Authentication
Use an AWS Access and Secret Key with admin privileges to execute this script 
> AWS_ACCESS_KEY_ID='XXXXXX' 
> AWS_SECRET_ACCESS_KEY='YYYYYY'
(or)
 >aws configure (provide AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY)
How to execute the script?
Please update the variable file according to the environmental specifications. 

All the variables contain on terraform.tfvars file  
( Optional ) Update AWS Access/Secret key in aws_api_route53_update.py in case, trying to access the another account route53 for host the domain name. if you're not setting this 
set the credentials here in the script

# Credentials
AWS_ACCESS_KEY_ID=''
AWS_SECRET_ACCESS_KEY='

comment on the following lines
# Access the environment constants
#try:
#AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
#except KeyError:
#logger.error("Please set the environment variable AWS_ACCESS_KEY_ID")
#sys.exit(FAILED_EXIT_CODE)
#try:
#AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
#except KeyError:
#logger.error("Please set the environment variable AWS_SECRET_ACCESS_KEY")
#sys.exit(FAILED_EXIT_CODE)


Command : 
- To get Help:

Usage: init.sh --action <action> --env <environment> --restoration <yes/no>
  Note: mandatory parameters --action <action> --env <environment> --restoration <yes/no>
  --action <action>
    init
    destroyCluster
  --env <environment>
    prod
    dev
    demo
    staging
  --restoration <yes/no>
 
- Script execution:-

init - execution
./init.sh --action init --env test --restoration <yes/no>


Destroy the DR
./init.sh --action destroyCluster --env test --restoration <yes/no>

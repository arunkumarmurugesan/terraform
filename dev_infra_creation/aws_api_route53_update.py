#!/usr/bin/python
#title           : aws_api_route53_update.py
#author          : Arunkumar M 
#date            : 27-08-2019
#usage           : python3 aws_api_route53_update.py --region <> --domain <> --clustername <> --elb <>/optional
#==============================================================================
import boto3
import json, time, argparse, logging, sys
import datetime
import os

# Credentials
#AWS_ACCESS_KEY_ID=''
#AWS_SECRET_ACCESS_KEY=''

FAILED_EXIT_CODE = 1
TODAY=datetime.datetime.now().strftime("%Y%m%d-%H%M")

# Enable the logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s", datefmt='%Y-%m-%d %H:%M:%S %Z')
ch.setFormatter(formatter)
logger.addHandler(ch)

# Access the environment constants
try:
    AWS_ACCESS_KEY_ID = os.environ["AWS_ACCESS_KEY_ID"]
except KeyError:
    logger.error("Please set the environment variable AWS_ACCESS_KEY_ID")
    sys.exit(FAILED_EXIT_CODE)
try:
    AWS_SECRET_ACCESS_KEY = os.environ["AWS_SECRET_ACCESS_KEY"]
except KeyError:
    logger.error("Please set the environment variable AWS_SECRET_ACCESS_KEY")
    sys.exit(FAILED_EXIT_CODE)

# Connect to AWS boto3 Client
def aws_connect_client(service,REGION):
    try:
        # Gaining API session
        #session = boto3.Session(aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_SECRET_ACCESS_KEY)
        session = boto3.Session()
        # Connect the client
        conn_client = session.client(service, REGION)
    except Exception as e:
        logger.error('Could not connect to region: %s and resources: %s , Exception: %s\n' % (REGION, service, e))
        conn_client = None
    return conn_client

def updateRoute53(REGION,DOMAIN_NAME,CLUSTER_NAME):
    # connects to Route53
    r53_client = aws_connect_client('route53', REGION)
    # Call the function and get the hostedzone id 
    HOSTEDZONEID = listHostedZone(REGION, DOMAIN_NAME)
    # Call the Function and get the ELB CNAME 
    ELB = getELB(REGION,CLUSTER_NAME)
    CLUSTER_NAME = "api.{}".format(CLUSTER_NAME)
    try:
        # Update the ELB CName in the route53
        response = r53_client.change_resource_record_sets(
            HostedZoneId=HOSTEDZONEID,
            ChangeBatch={
                'Comment': 'add %s -> %s' % (ELB, CLUSTER_NAME),
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': CLUSTER_NAME,
                            'Type': 'CNAME',
                            'TTL': 60,
                            'ResourceRecords': [{'Value': ELB}]
                        }
                    }]
            })
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:
            logger.info('Route53 record set was created for given domain name: {} ELB: {}'.format(CLUSTER_NAME,ELB))

    except Exception as e:
        logger.error('Not able to create route53 record set entry for given domain : {}, Exception: {}'.format(CLUSTER_NAME,e))
        raise e
        sys.exit(FAILED_EXIT_CODE)

def getELB(REGION,CLUSERNAME):
	# connects to Route53
    conn = aws_connect_client('elb', REGION)
    try:
        loadbalancer = conn.describe_load_balancers().get('LoadBalancerDescriptions', [])
    except Exception as e:
        logger.error("Unable to describe the loadbalancer. Exception: {}".format(e))
    # Get the ELB CName based the tag ( the value is domain name )
    for load in loadbalancer:
        LoadBalancerName = load['LoadBalancerName']
        response = conn.describe_tags(LoadBalancerNames=[LoadBalancerName])
        for t in response['TagDescriptions']:
            for tags in t.get('Tags'):
                if tags['Key'] == 'Name':
                    DOMAINNAME="api.{}".format(CLUSERNAME)
                    if tags.get('Value') == DOMAINNAME:
                        ELB=load['DNSName']
    return ELB

def listHostedZone(REGION,DOMAINNAME):
    # Get the HostedZone ID
    conn = aws_connect_client('route53', REGION)
    response = conn.list_hosted_zones()
    for i in response['HostedZones']:
        # Get the Public HostedZone ID based on the domain name 
        if i['Name'] == "{}.".format(DOMAINNAME) and i['Config']['PrivateZone'] == False:
            HOSTEDZONEID = str(i['Id']).split("/")[2]
    return HOSTEDZONEID

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='AWS Route53 Record Creation Script')
    parser.add_argument('--region', '-r', required=True, help='Specify the region.',type=str.lower)
    parser.add_argument('--loadbalancer', '-elb', help='Specify the ELB Name, It should be unique',type=str.lower)
    parser.add_argument('--domain', '-d', required=True, help='Specify the Domain Name, It should be unique',type=str.lower)
    parser.add_argument('--clustername', '-c', required=True, help='Specify the cluster name', type=str.lower)
    args = parser.parse_args()
    updateRoute53(args.region,args.domain,args.clustername)
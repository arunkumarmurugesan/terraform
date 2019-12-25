#!/bin/bash 
#title           :init.sh 
#description     :This script will create the DR env and restore the data.
#author          :Arunkumar M
#date            :27-Aug-2019
#version         :1.0
#usage           :./init.sh --action <action> --env <environment> --restoration <yes/no>
#==============================================================================
set -e

DATE=`date +%Y-%m-%d`
DATE_TIME=`date +%Y-%m-%d-%H:%M`
SCRIPTNAME=$(basename $0)
TERRAFORM=$(which terraform)
KOPS=$(which kops)
VELERO=$(which velero)
PYTHON=$(which python3)
LOG="terraform-$DATE.log"

function msg() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    SET='\033[0m'
    DATE_TIME=`date +%Y-%m-%d-%H:%M`
    local message="$1"
    echo -e "${GREEN}$DATE_TIME - INFO - $message ${SET}"
}
function error_exit() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    SET='\033[0m'
    DATE_TIME=`date +%Y-%m-%d-%H:%M`
    local message="$1"
    echo -e "${RED}$DATE_TIME - ERROR - $message ${SET}" 
    exit 1
}

function print_help () {
      echo -e "Usage: ${SCRIPTNAME} --action <action> --env <environment> --restoration <yes/no>"
      echo "  Note: mandatory parameters --action <action> --env <environment> --restoration <yes/no>"
      echo "  --action <action>"
      echo -e "\tinit"
      echo -e "\tdestroyCluster"
      echo "  --env <environment>"
      echo -e "\tprod"
      echo -e "\tdev"
      echo -e "\tdemo"
      echo -e "\tstaging"
      echo "  --restoration <yes/no>"
}

while test -n "$1"; do
   case "$1" in
       --help)
           print_help
           ;;
       -h)
           print_help
           ;;
        --action)
            [ -z "$action" ] && print_help && exit 1
            ACTION=$2
            shift
            ;;
        --env)
            [ -z "$env" ] && print_help && exit 1
            ENV=$2
            shift
            ;;
        --restoration)
            [ -z "$restoration" ] && print_help && exit 1
            RESTORATION=$2
            shift
            ;;
        --dryrun)
            shift
            ;;
       *)
            echo "Unknown argument: $1"
            print_help
            ;;
    esac
    shift
done

#print_help
function install_jq () {
  if [ "`which jq`" ]; then
    echo -e "`(jq --version)` had been installed already."
  else
    JQ=/usr/bin/jq
    curl https://stedolan.github.io/jq/download/linux64/jq > $JQ && chmod +x $JQ
   echo -e "Installed `(jq --version)`"
  fi
}

function install_terraform () {
  #Check if terraform is installed
  if [ "`which terraform`" ]; then
    echo -e "`(terraform --version)` had been installed already."
  else
    # Install terraform here
    echo -e "Installing terraform."
    wget https://releases.hashicorp.com/terraform/0.12.14/terraform_0.12.14_linux_amd64.zip
    unzip terraform_0.12.14_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    echo -e "Installed `(terraform --version)`"
  fi
}

function install_kops () {
   if [ "`which kops`" ]; then
     echo -e "`(kops version)` had been installed already."
   else 
     echo -e "Installing kops."
     wget -O kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
     chmod +x ./kops
     sudo mv ./kops /usr/local/bin/
     echo -e "Installed `(kops --version)`"
   fi
}

function install_velero () {
  #Check if terraform is installed
  if [ "`which velero`" ]; then
    echo -e "`(velero version)` had been installed already."
  else
    if [ "Darwin" = `uname -s` ]; then
      brew install velero
      echo -e "`(velero version)` had been installed now"
    else 
    # Install velero on the linux machine
    echo -e "Installing terraform."
    wget https://github.com/heptio/velero/releases/download/v1.1.0-beta.1/velero-v1.1.0-beta.1-linux-amd64.tar.gz
    tar -xf velero-v1.1.0-beta.1-linux-amd64.tar.gz
    sudo mv velero-v1.1.0-beta.1-linux-amd64/velero /usr/local/bin/
    echo -e "Installed `(velero --version)`"
    fi

  fi
}

function measureDataTime() {
    message=$1
    END_TIME=$(date +%s)
    NSECONDS=$((END_TIME - START_TIME))
    ELAPSED="${message} - Elapsed: $(($NSECONDS / 3600))hrs $((($NSECONDS / 60) % 60))min $(($NSECONDS % 60))sec"
    msg "${ELAPSED}"
}
function measureDataTimeOverALL() {
    message=$1
    MAIN_END_TIME=$(date +%s)
    OVERALLSECONDS=$((MAIN_END_TIME - MAIN_START_TIME))
    ELAPSED="${message} - Elapsed: $(($OVERALLSECONDS / 3600))hrs $((($OVERALLSECONDS / 60) % 60))min $(($OVERALLSECONDS % 60))sec"
    msg "${ELAPSED}"
}
function getStartTime() {
    START_TIME=$(date +%s)
}

#After creating the EC2 cluster with the configured instances etc, wait for Amazon to start them and pass checks
function validateCluster () {
  SECONDS=0
  while [ 1 ]; do
      ${KOPS} validate cluster ${NAME} && break || sleep 30
  done;
  measureDataTime "The kops cluster is ready now..."
}

function getVariables () {
      IMAGE_ID=$(terraform output image_id)
      DNS_ZONE=$(terraform output privatedns)
      export KOPS_STATE_STORE=$(terraform output kops_state_store)
      export NAME=$(terraform output clustername)
      VPC_ID=$(terraform output prod_vpcid)
      ZONES=$(terraform output availability_zones)
      KUBEVER=$(terraform output kube_version)
      MASTER_INSTANCE_TYPE=$(terraform output master_instance)
      NODE_INSTANCE_TYPE=$(terraform output node_instance)
      RL_MASTER_INSTANCE_TYPE=$(terraform output rl_node_instance)
      PROD_PRIVATE_SUBNET_IDS=($(terraform output -json prod_private_subnet_ids | tr -d '[|]' | tr "," " " | tr -d '"'))
      PROD_PUBLIC_SUBNET_IDS=($(terraform output -json prod_public_subnet_id | tr -d '[|]' | tr "," " " | tr -d '"'))
      PROD_NAT_GATEWAY_IDS=($(terraform output -json prod_nat_gatway_ids | tr -d '[|]' | tr "," " " | tr -d '"'))
      VPC_VAL=$(terraform output prod_vpc_cidr | awk -F"." '{print $1"."$2}')
      PROD_CIDR=$(terraform output prod_vpc_cidr)
      OPS_CIDR=$(terraform output ops_vpc_cidr)
      OFFICE_IPS=$(terraform output -json office_ips | tr -d "[|]")
      VELERO_ACCESS_ID=$(terraform output velero_user_access_key)
      VELERO_SECRET_ID=$(terraform output velero_user_access_key_secret)
      VELERO_BUCKET=$(terraform output dr_velero_backup_bucket)
      VELERO_BACKUPNAME=$(terraform output dr_velero_backup_name)
      NAMESPACE=$(terraform output dr_namespaces)
      REGION=$(terraform output dr_region)
      DOMAIN_NAME=$(terraform output domain_name)
      env=$(terraform output env)      
}
function aws_swipe_out() {
      python aws_swipe_out.py
}

function igCreation() {
      getStartTime
      ${KOPS} create ig realtime-logging --dry-run --output yaml > ${env}-ig-kubernetes.yaml
      sed -ie "s#image:.*#image: ${IMAGE_ID}#" ${env}-ig-kubernetes.yaml
      sed -ie "s#machineType.*#machineType: ${RL_MASTER_INSTANCE_TYPE}#" ${env}-ig-kubernetes.yaml
      sed -ie "s#maxSize.*#maxSize: 3#" ${env}-ig-kubernetes.yaml
      sed -ie "s#minSize.*#minSize: 3#" ${env}-ig-kubernetes.yaml
      lf=$'\n';sed -ie "s#nodeLabels.*#taints: \\$lf  - dedicated=true:NoSchedule\\$lf  nodeLabels:\\$lf    app: logging#" ${env}-ig-kubernetes.yaml    
      ${KOPS} create -f ${env}-ig-kubernetes.yaml
      [ $? -eq 0 ] && msg "The realtime-logging Instance group is created." || error_exit "Exection Failed: Cloud not able to create realtime-logging ig"
      measureDataTime "The realtime-logging exection is ended"
}

function restoreCluster() {
      install_velero
      getStartTime
      sed -ie "s#aws_access_key_id.*#aws_access_key_id="${VELERO_ACCESS_ID}"#" credentials_velero 
      sed -ie "s#aws_secret_access_key.*#aws_secret_access_key="${VELERO_SECRET_ID}"#" credentials_velero 
      dr_velero_backup=$(aws s3 ls s3://${VELERO_BUCKET}/backups/ --recursive | sort | tail -n 1 | awk -F'/' '{print $2}')
      ${VELERO} install --provider aws --bucket ${VELERO_BUCKET} --secret-file ./credentials_velero --backup-location-config region=${REGION}
      [ $? -eq 0 ] && msg "Velero server is installed on the cluster" || error_exit "Exection Failed: Cloud not able to velero server"
      while :
       do
          msg "Waiting for velero pod to become ready"
          sleep 5
          if kubectl get pods -n velero | grep velero | grep Running; then
              sleep 60
              break
          fi
       done
      ${VELERO} backup get 
      ${VELERO} restore create --from-backup ${VELERO_BACKUPNAME}
      while :
       do
          
          msg "Waiting for ${NAMESPACE} to create"
          sleep 5
          if kubectl get ns ${NAMESPACE}; then
              sleep 60
              break
          fi
       done

      while :
       do
          
          msg "Waiting for devtool-statefulset to create"
          sleep 5
          if kubectl get statefulset devtools-redis-statefulset -n ${NAMESPACE}; then
              kubectl delete statefulset devtools-redis-statefulset -n stage
              sleep 10
              kubectl create -f devjobs.yml
              kubectl create -f devtool-statefulset.yml
              break
          fi
       done
      measureDataTime "The velero restoration is ended"
}

function restorationData() {
      getStartTime
      ${PYTHON} restoration.py --velero yes --es yes --rds yes
      measureDataTime "The velero cofig change and ES restoration and DB Dump restoration is ended"
}

function updateRoute53() {
      getStartTime
      ${PYTHON} aws_api_route53_update.py -r ${REGION} -d ${DOMAIN_NAME} -c ${NAME}
      measureDataTime "The route53 record set is created for api domain"
}
function initDeployCluster () {
      cat /dev/null > ${LOG}
      getStartTime
      #aws_swipe_out
      install_jq
      install_terraform
      install_kops
      env=$(echo $ENV | awk '{print tolower($0)}')
      # Terraform init - initialize
      ${TERRAFORM} init | tee -a ${LOG} > /dev/null 2>&1
      [ $? -eq 0 ] && msg "The terraform init is initiated." || error_exit "Exection Failed: Cloud not able to initialize terraform init"
      ${TERRAFORM} workspace new ${env} | tee -a ${LOG}
      ${TERRAFORM} workspace list | tee -a ${LOG}
      [ $? -eq 0 ] && msg "Created the new workspace for the cluster : ${env} " || error_exit "Exection Failed: Cloud not able to create workspace"
      # Terraform plan to create the VPC/RDS/ES/SG.
      ${TERRAFORM} plan | tee -a ${LOG} > /dev/null 2>&1
      [ $? -eq 0 ] && msg "Successfully initiated the terraform plan to the VPC/RDS/ES/SG." || error_exit "Exection Failed: Cloud not able to initialize terraform plan to the VPC/RDS/ES/SG"
      # Terraform apply - create the aws VPC/RDS/ES/SG resources
      ${TERRAFORM} apply -auto-approve | tee -a ${LOG}
      [ $? -eq 0 ] && msg "Successfully created the VPC/RDS/ES/SG and Bastion Servers." || error_exit "Exection Failed: Cloud not able to create the VPC/RDS/ES/SG."
      measureDataTime "The Infrastructure creation (VPC/RDS/ES/SG) is ended"
      # Get the value from the Terraform and assign to the variabless
      getVariables
      getStartTime
      # Create the Kops Cluster
      ${KOPS} create cluster --cloud-labels "Environment=${env},Component=iot" --kubernetes-version ${KUBEVER} --master-zones ${ZONES} --zones ${ZONES} --dns-zone ${DNS_ZONE}  --vpc ${VPC_ID}  --master-size ${MASTER_INSTANCE_TYPE} --node-size ${NODE_INSTANCE_TYPE} --state ${KOPS_STATE_STORE} --image ${IMAGE_ID} --node-count 3 --topology private --api-loadbalancer-type public  --encrypt-etcd-storage --admin-access ${PROD_CIDR},${OPS_CIDR},${OFFICE_IPS} --ssh-access ${PROD_CIDR},${OPS_CIDR}  --networking calico  --dns private --authorization RBAC --cloud aws --target=terraform  --out=./modules/${env}/ ${NAME}
      #${KOPS} create cluster --cloud-labels "Environment=${env},Component=iot" --kubernetes-version ${KUBEVER} --master-zones ${ZONES} --zones ${ZONES} --dns-zone ${DNS_ZONE}  --vpc ${VPC_ID}  --master-size ${MASTER_INSTANCE_TYPE} --node-size ${NODE_INSTANCE_TYPE} --state ${KOPS_STATE_STORE} --image ${IMAGE_ID} --node-count 3 --topology private --api-loadbalancer-type public --networking calico  --dns private --authorization RBAC --cloud aws --target=terraform  --out=. ${NAME}
      [ $? -eq 0 ] && msg "Successfully initiated the Kops cluster creation" || error_exit "Exection Failed: Cloud not able to initialize the kops cluster creation"
      # Get the cluster configuration in yaml file in order to change the VPC attributes  
      ${KOPS} get cluster ${NAME} -o yaml > ${env}-kubernetes.yaml
      [ $? -eq 0 ] && msg "Get the cluster configuration in the yaml." || error_exit "Exection Failed: Cloud not able to get the kops cluster yaml"
      # Update the cluster configuration 
      lf=$'\n';sed -ie "s#- cidr: ${VPC_VAL}.32.0\/19#- egress: ${PROD_NAT_GATEWAY_IDS[0]}\\$lf    id: ${PROD_PRIVATE_SUBNET_IDS[0]}#" ${env}-kubernetes.yaml
      lf=$'\n';sed -ie "s#- cidr: ${VPC_VAL}.64.0\/19#- egress: ${PROD_NAT_GATEWAY_IDS[1]}\\$lf    id: ${PROD_PRIVATE_SUBNET_IDS[1]}#" ${env}-kubernetes.yaml
      lf=$'\n';sed -ie "s#- cidr: ${VPC_VAL}.96.0\/19#- egress: ${PROD_NAT_GATEWAY_IDS[2]}\\$lf    id: ${PROD_PRIVATE_SUBNET_IDS[2]}#" ${env}-kubernetes.yaml
      lf=$'\n';sed -ie "s#- cidr: ${VPC_VAL}.0.0\/22#- id: ${PROD_PUBLIC_SUBNET_IDS[0]}#" ${env}-kubernetes.yaml
      lf=$'\n';sed -ie "s#- cidr: ${VPC_VAL}.4.0\/22#- id: ${PROD_PUBLIC_SUBNET_IDS[1]}#" ${env}-kubernetes.yaml
      lf=$'\n';sed -ie "s#- cidr: ${VPC_VAL}.8.0\/22#- id: ${PROD_PUBLIC_SUBNET_IDS[2]}#" ${env}-kubernetes.yaml
      # Replace the cluster yaml with updated cluster configurations
      ${KOPS} replace -f ${env}-kubernetes.yaml
      [ $? -eq 0 ] && msg "Replaced the kubernetes yaml" || error_exit "Exection Failed: Cloud not able to replace the kubernetes yaml."
      igCreation
      ${KOPS} update cluster --out=./modules/${env}/ --target=terraform ${NAME}
      #[ $? -eq 0 ] && msg "The kubernetes cluster creation is updated in terraform." || error_exit "Exection Failed: Cloud not able to update the kubernetes cluster."
      sed -ie "s#root_block_device =#root_block_device#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#alias =#alias#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#listener =#listener#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#health_check =#health_check#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#tag =#tag#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#lifecycle =#lifecycle#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#locals =#locals#g" ./modules/${env}/kubernetes.tf
      sed -ie "s#terraform =#terraform#g" ./modules/${env}/kubernetes.tf
      echo -ne '\nmodule "'${env}'" { \n source          = "./modules/'${env}'" \n}' >> main.tf
      # Terraform init - initialize
      ${TERRAFORM} init | tee -a ${LOG} > /dev/null 2>&1
      # Terraform plan - for kops cluster creation
      ${TERRAFORM} plan | tee -a ${LOG} > /dev/null 2>&1
      [ $? -eq 0 ] && msg "Successfully initiated the terraform plan for kops cluster creation" || error_exit "Exection Failed: Cloud not able to initialize terraform plan for kops cluster creation"
      # Terraform apply - Create the Kops Cluster
      ${TERRAFORM} apply -auto-approve | tee -a ${LOG}
      [ $? -eq 0 ] && msg "Successfully created the Kops cluster." || error_exit "Exection Failed: Cloud not able to create the Kops cluster."
      # Terraform Output - Print the ALL resources created by Terraform
      measureDataTime "kops cluster creation (master/node/realtimelogging node ) is ended"
      msg "The Cluster has been created successfully. Please find the resources details below."
      ${TERRAFORM} output -json 
      ${TERRAFORM} output -json > output.json
      updateRoute53
      validateCluster
      if [ "$RESTORATION" = "yes" ];then
          restorationData
          restoreCluster
      fi
      python aws-security-fix.py -r $REGION -s3 $S3_BUCKET_NAME -e $EMAIL_ADDRESS -k k8s
}

function destoryCluster () {
      env_lc=$(echo $ENV | awk '{print tolower($0)}')
      ${TERRAFORM} workspace select ${env_lc}
      ${TERRAFORM} destroy -auto-approve
      [ $? -eq 0 ] && msg "The Cluster has been destroyed successfully." || error_exit "Exection Failed: Cloud not able to destroy the cluster"
}

main () {
    if [ "$ACTION" = "init" ];then
        # The action will provision the infra and requried resource
        MAIN_START_TIME=$(date +%s)
        initDeployCluster
        measureDataTimeOverALL "All done!. The DR env is creation ended"
        echo -e $'\360\237\215\273\360\237\215\273\360\237\215\273\360\237\215\273 DR is ready \360\237\215\273\360\237\215\273\360\237\215\273\360\237\215\273'
    elif [ "$ACTION" = "destroyCluster" ];then
        # The action will destory the cluster based on the terraform state.
        destoryCluster
    else
       print_help
    fi
}

# Calling Main Function to execute script
main


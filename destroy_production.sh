#!/bin/bash

# The following script is used to tear down any production environment that was created by the orchestrator.sh script.

# Take input of the AWS profile and region to use as arguments called profile and region
# check for args
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    exit 1
fi

#----------------------- AWS SETUP CHECKS -----------------------# 

# check for profile arg
if [ -z "$1" ]; then
    echo "Profile argument is empty"
    exit 1
fi

# check for region arg
if [ -z "$2" ]; then
    echo "Region argument is empty"
    exit 1
fi

# check if aws cli is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found"
    exit 1
fi

# check if aws cli is configured
if ! aws configure list &> /dev/null
then
    echo "AWS CLI is not configured"
    exit 1
fi

# check if profile exists
if ! grep -q "\[$1\]" ~/.aws/credentials; then
    echo "Profile does not exist"
    exit 1
fi

# ----------------------- END AWS SETUP CHECKS -----------------------#

profile=$1
region=$2

# ----------------------- Terraform & SSM PARAM STORE-----------------------#
cd terraform/lightsail
terraform init
terraform destroy -auto-approve -var "aws_profile=$profile" -var "region=$region"
cd ../..

aws ssm delete-parameters --names `aws ssm get-parameters-by-path --path /uptime-kuma/ --query Parameters[].Name --output text --profile $profile --region $region` --profile $profile --region $region
# ----------------------- END Terraform & SSM PARAM STORE-----------------------#


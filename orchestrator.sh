#!/bin/bash

# The following script is used to orchestrate the execution of the scripts folder.

#  To run this script, run the following command:
# ./orchestrator.sh <aws_profile> <aws_region>
# e.g. ./orchestrator.sh default us-east-1


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
terraform apply -auto-approve -var "aws_profile=$profile" -var "region=$region"

# create new random user (admin with postfix of 6 random chars) and password (random) for admin and save in SSM Parameter Store
admin_user=admin_$(openssl rand -hex 3)
admin_pass=$(openssl rand -hex 5)

aws ssm put-parameter --name "/uptime-kuma/username" --value "$admin_user" --type "SecureString" --profile $profile --region $region
aws ssm put-parameter --name "/uptime-kuma/password" --value "$admin_pass" --type "SecureString" --profile $profile --region $region

# Go back to root directory
cd ../../

# get endpoint
endpoint=$(aws lightsail get-container-services --service-name backup-uptime-kuma --profile $profile --region $region --query 'containerServices[0].url' --output text)

# check that the container is running by hitting the endpoint, if it returns a 200, then it is running and can continue with the script, else wait 15 seconds and try again
while true; do
    curl $endpoint
    if [ $? -eq 0 ]; then
        break
    else
        sleep 15
    fi
done

# ----------------------- END Terraform & SSM PARAM STORE-----------------------#

# ----------------------- SCRIPTS -----------------------#

# create python virtual environment in the scripts folder
cd scripts
python3 -m venv venv
source venv/bin/activate

# install dependencies
pip install -r requirements.txt

# Run the scripts
# create admin user
echo "Creating admin user"
python3 create_admin_user.py -u $admin_user -p $admin_pass -d $endpoint

# wait 3 seconds for the admin user to be created
sleep 3

# add monitors
echo "Adding monitors"
python3 add_monitors.py -u $admin_user -p $admin_pass -f health_check_urls_with_interval.txt -d $endpoint

# AWS lightsail command to get endpoint
echo "Endpoint: $(aws lightsail get-container-services --service-name backup-uptime-kuma --profile $profile --region $region --query 'containerServices[0].url' --output text)"

# Print the AWS CLI command to retrieve the username and password values from AWS parameter store
echo "Use the following ssm commands to retrieve the username and password from AWS parameter store"
echo "aws ssm get-parameter --name /uptime-kuma/username --with-decryption --region $region --profile $profile --output text --query Parameter.Value"
echo "aws ssm get-parameter --name /uptime-kuma/password --with-decryption --region $region --profile $profile --output text --query Parameter.Value"



# ----------------------- END SCRIPTS -----------------------#

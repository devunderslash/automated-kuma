# Backup Uptime-Kuma

This repo is designed to provide an instant backup solution to monitor health check endpoints if Datadog is down.

## Requirements
- Terminal or Windows Subsystem for Linux (WSL) with Bash
- Docker 20.10.7+ (Optional if you want to run Uptime-Kuma locally)
- Python 3.6+
- Terraform 1.0.0+
- AWS CLI 2.2.0+

## Add URLs 
- Add URLs and monitor interval that you want to monitor in the scripts/health_check_urls_with_interval.txt file. There are some examples in the file already. 

## How to run locally (single-step)
1. Clone this repo
2. Run the following command:
```bash
sh local_orchestrator.sh
```

## How to run locally (multi-step)
1. Clone this repo
2. Spin up an Uptime-Kuma container
```bash
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:latest 
```
3. Create a virtual environment within the script folder
```bash
python3 -m venv venv
```
4. Activate the virtual environment
```bash
source venv/bin/activate
```
5. Install the requirements
```bash
pip install -r requirements.txt
```
6. Run the scripts in the following order:
- Create an admin user:
```bash
python3 create_admin_user.py -u admin -p admin_testing123
```
- Add Monitors:
```bash
add_monitors.py -u admin -p admin_testing123 -f health_check_urls_with_interval.txt
```
7. Open http://localhost:3001/ and login with the admin credentials


## How to destroy the setup locally
1. Run the following command:
```bash
sh destroy_local.sh 
```

## How to run on AWS Lightsail (single-step)
1. Clone this repo
2. You must have an AWS account with an ECR repository with the name "uptime-kuma" in the region you want to deploy to.
2. Ensure you have the correct AWS credentials in your environment. This setup uses a profile var to select the correct credentials:
```bash
sh orchestrator.sh <aws profile> <aws region>
``` 
3. Wait for the setup to complete, get credentials from AWS Param store and open the URL provided in the output.

## How to run on AWS Lightsail (multi-step)
1. Clone this repo
2. You must have an AWS account with an ECR repository with the name "uptime-kuma" in the region you want to deploy to.
2. Ensure you have the correct AWS credentials in your environment. This setup uses a profile var to select the correct credentials:
3. Run terraform 
```bash
terraform init
terraform apply -var 'aws_profile=<aws profile>' -var 'aws_region=<aws region>'
```
4. Get endpoint from the following command:
```bash
aws lightsail get-container-services --service-name backup-uptime-kuma --profile $profile --region $region --query 'containerServices[0].url' --output text
```
5. Open the URL provided in the output.
6. Run the create admin user script:
```bash
python3 create_admin_user.py -u <username> -p <password> -d <endpoint>
```
7. Run the add monitors script:
```bash
add_monitors.py -u <username> -p <password> -f health_check_urls_with_interval.txt -d <endpoint>
```

### How to destroy the setup
1. Run the following command:
```bash
sh destroy_production.sh <aws profile> <aws region>
```


## TODO:
- Create automated backend statefile management (S3 bucket and DynamoDB table)
- Write github action to run the setup on AWS


## References:
- Uptime Kuma: https://github.com/louislam/uptime-kuma 
- Uptime Kuma API: https://uptime-kuma-api.readthedocs.io/en/latest/
- Terraform AWS Lightsail: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lightsail_container_service 

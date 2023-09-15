# Create a new random username and password and store it in AWS parameter store
import boto3
import string
import random
import argparse

parser = argparse.ArgumentParser(description='Create a new admin user for uptime kuma')
parser.add_argument('-r', '--region', help='aws region', required=True)
parser.add_argument('-n', '--name', help='name of the user', required=True)
parser.add_argument('-p', '--password', help='password for the user', required=True)
args = parser.parse_args()

# Base for a new random username and password
username = args.name
password = args.password

# create a new boto3 session
session = boto3.session.Session(region_name=args.region)

# create a new ssm client
ssm_client = session.client('ssm')

# create a new random username and password
username = ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))
password = ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))

# store the username and password in parameter store
ssm_client.put_parameter(
    Name='/uptime-kuma/username',
    Description='Username for uptime kuma',
    Value=username,
    Type='SecureString',
    Overwrite=True
)

ssm_client.put_parameter(
    Name='/uptime-kuma/password',
    Description='Password for uptime kuma',
    Value=password,
    Type='SecureString',
    Overwrite=True
)

# Print the AWS CLI command to retrieve the username and password
print("Use the following ssm commands to retrieve the username and password from AWS parameter store")
print(f"aws ssm get-parameter --name /uptime-kuma/username --with-decryption --region {args.region}")
print(f"aws ssm get-parameter --name /uptime-kuma/password --with-decryption --region {args.region}")

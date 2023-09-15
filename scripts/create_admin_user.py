from uptime_kuma_api import UptimeKumaApi
import argparse


parser = argparse.ArgumentParser(description='Add monitors to uptime kuma')
parser.add_argument('-u', '--username', help='username for uptime kuma', required=True)
parser.add_argument('-p', '--password', help='password for uptime kuma', required=True)
parser.add_argument('-d', '--domain', help='domain for uptime kuma', required=False, default="http://localhost:3001")
args = parser.parse_args()

api = UptimeKumaApi(args.domain)

# check if setup is needed
if not api.need_setup():
    print("Setup is not needed")
    exit(0)

username = args.username
password = args.password

# setup the api
api.setup(username, password)

# logout of the api
api.disconnect()

# print url to login to uptime kuma
# print(f"Login to uptime kuma at {args.domain}/login")

import time
from uptime_kuma_api import UptimeKumaApi, MonitorType
import argparse


parser = argparse.ArgumentParser(description='Add monitors to uptime kuma')
parser.add_argument('-u', '--username', help='username for uptime kuma', required=True)
parser.add_argument('-p', '--password', help='password for uptime kuma', required=True)
parser.add_argument('-d', '--domain', help='domain for uptime kuma', required=False, default="http://localhost:3001")
parser.add_argument('-f', '--filename', help='file containing urls to add', required=True)
args = parser.parse_args()


api = UptimeKumaApi(args.domain)
api.login(args.username, args.password)

with open(args.filename, 'r') as f:
    urls = f.readlines()

urls = [url.strip() for url in urls]
counter = 1

# loop through each url
for url in urls:
    url,interval = url.split(',')
    # get the first part of the url after the https:// and before the first dot
    name = url.split('https://')[1].split('.')[0]

    friendly_name = name 

    # convert the interval to an int
    interval = int(interval)

    result = api.add_monitor(type=MonitorType.HTTP, name=friendly_name, url=url, maxretries=3, interval=interval, retryInterval=120)

    counter += 1

    # print output to a new file called monitor_names.txt
    with open('monitor_names.txt', 'w') as f:
        f.write(friendly_name + '\n')

# close the file
f.close()

# logout of the api
api.disconnect()

print(f"Login to uptime kuma at {args.domain}/login")

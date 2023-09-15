from uptime_kuma_api import UptimeKumaApi
import argparse


parser = argparse.ArgumentParser(description='Username and password for deleting monitors')
parser.add_argument('-u', '--username', help='name of the user', required=True)
parser.add_argument('-p', '--password', help='password for the user', required=True)
parser.add_argument('-d', '--domain', help='domain for uptime kuma', default="http://localhost:3001")
parser.add_argument('-f', '--filename', help='file containing urls to add', required=True)
args = parser.parse_args()

api = UptimeKumaApi(args.domain)

# Username and password for deleting monitors
username = args.username
password = args.password
filename = args.filename

# login to the api
api.login(username, password)

# count the number of lines in the file
with open(filename, 'r') as f:
    lines = f.readlines()
    count = len(lines)

# with number of lines set id to number and loop the id to delete each monitor
for i in range(1, count + 1):
    api.delete_monitor(i)

# get all the tags
tags_to_delete = api.get_tags()

# loop through each tag and delete it
for tag in tags_to_delete:
    api.delete_tag(tag['id'])

# clear the statistics
api.clear_statistics()

# close the file
# f.close()

# logout of the api
api.disconnect()

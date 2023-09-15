#!/bin/bash

# The following script is used to orchestrate the execution of the scripts folder. It is to imitate how this would be set up in a production environment. It is not to be used in production.

# check for running container of uptime-kuma, if it exists, then stop and remove it
if [ "$(docker ps -q -f name=uptime-kuma)" ]; then
    docker stop uptime-kuma
    docker rm uptime-kuma
fi

# check for volume of uptime-kuma, if it exists, then remove it
if [ "$(docker volume ls -q -f name=uptime-kuma)" ]; then
    docker volume rm uptime-kuma
fi

# run instance of uptime-kuma
docker run -d --restart=always -p 3001:3001 -v uptime-kuma:/app/data --name uptime-kuma louislam/uptime-kuma:latest 

# check that the container is running by hitting the endpoint, if it returns a 200, then it is running and can continue with the script, else wait 10 seconds and try again
while true; do
    curl http://localhost:3001
    if [ $? -eq 0 ]; then
        break
    else
        sleep 10
    fi
done

# create python virtual environment in the scripts folder
cd scripts
python3 -m venv venv
source venv/bin/activate

# install dependencies
pip install -r requirements.txt

# run the scripts
# create admin user, if there is an echo of "Setup is not needed", then the admin user already exists and the script will not run, exit with error code 1
echo "Creating admin user"
python3 create_admin_user.py -u admin -p admin_testing123 
if [ $? -eq 1 ]; then
    exit 1
fi

# add monitors
echo "Adding monitors"
python3 add_monitors.py -u admin -p admin_testing123 -f health_check_urls_with_interval.txt

# print endppoint and login credentials
echo "Endpoint: http://localhost:3001"
echo "Username: admin"
echo "Password: admin_testing123"

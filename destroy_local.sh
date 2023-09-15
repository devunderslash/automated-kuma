#!/bin/bash

# The following script is used to bring down the running uptime-kuma container and remove it.

# check for running container of uptime-kuma, if it exists, then stop and remove it
if [ "$(docker ps -q -f name=uptime-kuma)" ]; then
    docker stop uptime-kuma
    docker rm uptime-kuma
fi

# remove the volume
if [ "$(docker volume ls -q -f name=uptime-kuma)" ]; then
    docker volume rm uptime-kuma
fi

# remove the image (optional)
# docker image rm louislam/uptime-kuma:latest

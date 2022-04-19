#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

_file="/etc/docker/daemon.json"
_service="docker.service"

## Stop Docker Service
if [[ $(systemctl is-active ${_service}) == "active" ]]; then
    systemctl stop ${_service}
fi

## Create daemon.json file along with the following lines.
if [[ ! -f ${_file} ]]; then
    echo "{
  \"storage-driver\": \"vfs\"
}" > ${_file}
fi

## Start Docker Service
systemctl start ${_service}

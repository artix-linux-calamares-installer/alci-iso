#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

_file="/etc/docker/daemon.json"

## Stop Docker Service
if [[ $(sv status docker; echo "$?") == "0" ]]; then
    sv stop ${_service}
    rm -rf /run/runit/service/docker
fi

## Create daemon.json file along with the following lines.
if [[ ! -f ${_file} ]]; then
    mkdir -p /etc/docker/
    echo "{
  \"storage-driver\": \"vfs\"
}" > ${_file}
fi

## Start Docker Service
ln -sf /etc/runit/sv/docker /run/runit/service/
sv start docker

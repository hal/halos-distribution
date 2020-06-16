#!/usr/bin/env bash


# Script to start / stop halOS.
#
# Parameter
#   1. start|stop
#   2. port
#
# What it does
#   1. Pull halOS (if necessary)
#   2. Start / stop halOS docker container
#   3. Create a network for talking to WildFly instances


NETWORK=halos-net


if [[ $# -lt 1 ]]
then
    echo "Please use $0 start|stop <port>"
    exit 1
fi

command=$1
if [[ $command == "start" ]]
then
  if [[ -z $2 ]]
  then
    echo "Please use $0 start <port>"
    exit 1
  fi
  port=$2
  docker network inspect $NETWORK >/dev/null 2>&1 || docker network create $NETWORK
  docker run --name halos -p $port:8080 --detach --rm --network $NETWORK quay.io/halconsole/halos:latest
elif [[ $command == "stop" ]]
then
  docker stop halos
fi

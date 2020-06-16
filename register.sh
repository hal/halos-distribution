#!/usr/bin/env bash


# Script to start / stop WildFly instances and register them against halOS.
#
# Prerequisites
#   - Running halOS
#   - Docker network 'halos'
#
# Parameter
#   1. +-<name>
#
# What it does
#   1. Start / stop WildFly instances
#   2. Register / unregister them against halOS


NETWORK=halos-net


function startWildFly() {
  server=$1
  docker image inspect halconsole/wildfly > /dev/null 2>&1 || docker build -t halconsole/wildfly .
  echo "Start $server..."
  docker run --name "$server" --detach --rm --network $NETWORK halconsole/wildfly
  grep -m 1 "started in" <(docker logs -f "$server")
  sleep 1
  echo "DONE"
}


function stopWildFly() {
  server=$1
  echo "Stop $server"
  docker stop "$server"
}


function registerWildFly() {
  server=$1
  curl --url "http://localhost:8080/v1/instance/" \
--header 'content-type: application/json' \
--data "{\"name\":\"$server\",\"host\":\"$server\",\"port\":9990,\"username\":\"admin\",\"password\":\"admin\"}"
}


function unregisterWildFly() {
  server=$1
  curl --request DELETE --url "http://localhost:8080/v1/instance/$server"
}


for var in "$@"
do
  if [[ $var =~ ^([+-])([A-Za-z0-9]+) ]]
  then
    op=${BASH_REMATCH[1]}
    server=${BASH_REMATCH[2]}
    if [[ $op == "+" ]]
    then
      startWildFly "$server"
      registerWildFly "$server"
    elif [[ $op == "-" ]]
    then
      stopWildFly "$server"
      unregisterWildFly "$server"
    else
      echo "Invalid argument: '$var'"
    fi
  else
    echo "Invalid argument: '$var'"
    exit 1
  fi
done

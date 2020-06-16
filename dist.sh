#!/usr/bin/env bash


# Script to package and distribute halOS (proxy and console).
#
# Prerequisites
#   - Sibling directories: 'halos-console' and 'halos-proxy'
#   - Configured credentials to deploy to quay.io
#
# What it does
#   1. Assemble halos-console
#   2. Build halos-proxy
#   3. Deploy halos to 'https://quay.io/repository/halconsole/halos'


ROOT=$PWD
BASEDIR=$(dirname "$PWD")
HALOS_CONSOLE=$BASEDIR/halos-console
HALOS_PROXY=$BASEDIR/halos-proxy


echo "Assemble halOS console"
cd "$HALOS_CONSOLE" || { echo "halOS console directory at '$HALOS_CONSOLE' not found" ; exit 1; }
./gradlew assemble


echo "Install halOS console"
mvn install


echo "Install halOS proxy"
cd "$HALOS_PROXY" || { echo "halOS proxy directory at '$HALOS_PROXY' not found" ; exit 1; }
mvn install -Dquarkus.container-image.registry=quay.io -Dquarkus.container-image.group=halconsole -Dquarkus.container-image.name=halos -Dquarkus.container-image.tag=latest -Dquarkus.container-image.insecure=true


cd "$ROOT" || exit 1
echo "DONE"

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


printf "Assemble halOS console\n"
cd "$HALOS_CONSOLE" || { printf "halOS console directory at '$HALOS_CONSOLE' not found" ; exit 1; }
./gradlew assemble


printf "\n\n\nInstall halOS console\n"
mvn install


printf "\n\n\nInstall halOS proxy\n"
cd "$HALOS_PROXY" || { printf "halOS proxy directory at '$HALOS_PROXY' not found" ; exit 1; }
mvn install -Dquarkus.container-image.build=true -Dquarkus.container-image.push=true -Dquarkus.container-image.registry=quay.io -Dquarkus.container-image.group=halconsole -Dquarkus.container-image.name=halos -Dquarkus.container-image.tag=latest -Dquarkus.container-image.insecure=true


cd "$ROOT" || exit 1
printf "\n\n\nDONE\n"

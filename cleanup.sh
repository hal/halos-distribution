#!/usr/bin/env bash
#
#  Copyright 2022 Red Hat
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

VERSION=0.0.1

# Change into the script's directory
# Using relative paths is safe!
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
readonly script_dir
cd "${script_dir}"

usage() {
  cat <<EOF
USAGE:
    $(basename "${BASH_SOURCE[0]}") [FLAGS] all|halos|services

FLAGS:
    -d, --dev           Apply development settings
    -h, --help          Prints help information
    -v, --version       Prints version information
    --no-color          Uses plain text output

ARGUMENTS:
    all                 Cleanup everything
    openshift           Cleanup service account, roles and role binding
    halos               Undeploy halOS service and routes
    services            Undeploy WildFly and Quarkus demo services
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    # shellcheck disable=SC2034
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

version() {
  msg "${BASH_SOURCE[0]} $VERSION"
  exit 0
}

parse_params() {
  DEVELOPMENT=false
  while :; do
    case "${1-}" in
      -d | --dev) DEVELOPMENT=true ;;
      -h | --help) usage ;;
      -v | --version) version ;;
      --no-color) NO_COLOR=1 ;;
      -?*) die "Unknown option: $1" ;;
      *) break ;;
    esac
    shift
  done

  args=("$@")
  [[ ${#args[@]} -eq 0 ]] && die "Missing argument. Please specify one of all|halos|services"
  MODULE=${args[0]}

  return 0
}

all() {
  halos
  services
}

halos() {
  msg
  msg "Cleanup ${CYAN}halOS${NOFORMAT}"
  oc delete route halos --ignore-not-found
  oc delete service halos --ignore-not-found
  oc delete dc halos --ignore-not-found
  oc delete is halos --ignore-not-found
}

services() {
  msg
  msg "Cleanup ${CYAN}services${NOFORMAT}"
  oc delete deployments --selector managedby=halos --ignore-not-found
  oc delete services --selector managedby=halos --ignore-not-found
  oc delete route wildfly-thread-racing --ignore-not-found
  oc delete route quarkus-demo --ignore-not-found

  if [[ "${DEVELOPMENT}" == "true" ]]; then
    msg
    msg "Cleanup ${CYAN}services${NOFORMAT} for ${YELLOW}development${NOFORMAT}"
    oc delete routes --selector managedby=halos --ignore-not-found
  fi
}

parse_params "$@"
setup_colors
[ -x oc ] && die "OpenShift command line tools not available. See https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli"

case "${MODULE-}" in
  all) all ;;
  halos) halos ;;
  services) services ;;
  *) die "Illegal argument: $1. Please specify one of all|halos|services" ;;
esac



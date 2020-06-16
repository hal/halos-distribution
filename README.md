# halOS Distribution

This repository contains scripts to play with halOS and to distribute it to [quay.io](https://quay.io) 

## Get Started

1. Start halOS: `halos.sh start 8080`
1. Open http://localhost:8080
1. Start and register WildFly instances: `register.sh +wf0 +wf1 +wf2`
1. Watch http://localhost:8080/#server
1. Stop and unregister WildFly instance: `register.sh -wf0 -wf1 -wf2`

## Scripts

- `dist.sh` Package halOS and push it to https://quay.io/halconsole/halos
- `halos.sh` Start and stop halOS
- `register.sh` Start and register / stop and unregister WildFly instances against halOS

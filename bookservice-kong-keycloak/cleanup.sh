#!/usr/bin/env bash

helm delete my-mysql
helm delete my-mongodb
helm delete my-keycloak
helm delete my-postgres
helm delete my-kong

kubectl delete -f yaml-files/bookservice-deployment.yaml

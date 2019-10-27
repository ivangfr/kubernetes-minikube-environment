#!/usr/bin/env bash

helm delete --purge my-mysql
helm delete --purge my-mongodb
helm delete --purge my-keycloak

helm delete --purge my-kong
kubectl delete pvc data-my-kong-postgresql-0

kubectl delete -f yaml-files/bookservice-deployment.yaml

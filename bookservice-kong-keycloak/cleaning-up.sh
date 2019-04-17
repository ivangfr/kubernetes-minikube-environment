#!/usr/bin/env bash

helm delete --purge my-mysql
helm delete --purge my-mongodb
helm delete --purge my-postgres
helm delete --purge my-keycloak

#helm delete --purge my-kong
kubectl delete -f yaml-files/kong-migration-job.yaml
kubectl delete -f yaml-files/kong-deployment.yaml

kubectl delete -f yaml-files/bookservice-deployment.yaml

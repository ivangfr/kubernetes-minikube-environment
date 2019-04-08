#!/usr/bin/env bash

kubectl delete -f yaml-files/mysql-keycloak-deployment.yaml
kubectl delete -f yaml-files/postgres-kong-deployment.yaml
kubectl delete -f yaml-files/mongodb-bookservice-deployment.yaml

kubectl delete -f yaml-files/kong-migration-job.yaml

kubectl delete -f yaml-files/kong-deployment.yaml
kubectl delete -f yaml-files/keycloak-deployment.yaml

kubectl delete -f yaml-files/bookservice-deployment.yaml

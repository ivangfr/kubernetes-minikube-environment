#!/usr/bin/env bash

kubectl create -f deployment-files/mysql-keycloak-deployment.yaml
kubectl create -f deployment-files/postgres-kong-deployment.yaml
kubectl create -f deployment-files/mongodb-bookservice-deployment.yaml

sleep 20

kubectl create -f deployment-files/kong-migration-job.yaml

sleep 5

kubectl create -f deployment-files/kong-deployment.yaml
kubectl create -f deployment-files/keycloak-deployment.yaml
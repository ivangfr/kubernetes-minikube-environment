#!/usr/bin/env bash

kubectl apply -f yaml-files/mysql-keycloak-deployment.yaml
kubectl apply -f yaml-files/postgres-kong-deployment.yaml
kubectl apply -f yaml-files/mongodb-bookservice-deployment.yaml

sleep 20

kubectl apply -f yaml-files/kong-migration-job.yaml

sleep 5

kubectl apply -f yaml-files/kong-deployment.yaml
kubectl apply -f yaml-files/keycloak-deployment.yaml
#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

KONG_8001_PORT=$(kubectl get services/kong-admin-service -o go-template='{{(index .spec.ports 0).nodePort}}')
KONG_8000_PORT=$(kubectl get services/kong-proxy-service -o go-template='{{(index .spec.ports 0).nodePort}}')
KEYCLOAK_PORT=$(kubectl get services/keycloak-service -o go-template='{{(index .spec.ports 0).nodePort}}')

KONG_ADDR_8001="$MINIKUBE_IP:$KONG_8001_PORT"
KONG_ADDR_8000="$MINIKUBE_IP:$KONG_8000_PORT"
KEYCLOAK_ADDR="$MINIKUBE_IP:$KEYCLOAK_PORT"

echo "export KONG_ADDR_8001=$KONG_ADDR_8001"
echo "export KONG_ADDR_8000=$KONG_ADDR_8000"
echo "export KEYCLOAK_ADDR=$KEYCLOAK_ADDR"
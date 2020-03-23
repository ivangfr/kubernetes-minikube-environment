#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

KONG_ADMIN_PORT=$(kubectl get services -n dev my-kong-kong-admin -o go-template='{{(index .spec.ports 0).nodePort}}')
KONG_PROXY_PORT=$(kubectl get services -n dev my-kong-kong-proxy -o go-template='{{(index .spec.ports 0).nodePort}}')
KEYCLOAK_PORT=$(kubectl get services -n dev my-keycloak-http -o go-template='{{(index .spec.ports 0).nodePort}}')

KONG_ADMIN_URL="$MINIKUBE_IP:$KONG_ADMIN_PORT"
KONG_PROXY_URL="$MINIKUBE_IP:$KONG_PROXY_PORT"
KEYCLOAK_URL="$MINIKUBE_IP:$KEYCLOAK_PORT"

echo "export KONG_ADMIN_URL=$KONG_ADMIN_URL"
echo "export KONG_PROXY_URL=$KONG_PROXY_URL"
echo "export KEYCLOAK_URL=$KEYCLOAK_URL"

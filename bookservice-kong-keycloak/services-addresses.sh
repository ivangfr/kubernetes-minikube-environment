#!/usr/bin/env bash

echo "export KONG_8001_URL=$(minikube service kong-admin-service --url)"
echo "export KONG_8000_URL=$(minikube service kong-proxy-service --url)"
echo "export KEYCLOAK_URL=$(minikube service keycloak-service --url)"
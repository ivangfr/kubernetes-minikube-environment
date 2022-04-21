#!/usr/bin/env bash

if [[ -z "$1" ]]; then
  echo "WARNING: BOOK_SERVICE_CLIENT_SECRET must be informed as 1st parameter"
  exit 1
fi

BOOK_SERVICE_CLIENT_SECRET=$1
KEYCLOAK_HOST_PORT=${2:-"my-keycloak-keycloakx-http"}

BOOK_SERVICE_POD=$(kubectl get pods --namespace dev -l app=bookservice -o go-template='{{(index .items 0).metadata.name}}')

ACCESS_TOKEN_FULL=$(kubectl exec --namespace dev $BOOK_SERVICE_POD -- sh -c '
  curl -s -X POST http://'$KEYCLOAK_HOST_PORT'/realms/company-services/protocol/openid-connect/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=ivan.franchin" \
    -d "password=123" \
    -d "grant_type=password" \
    -d "client_secret='$BOOK_SERVICE_CLIENT_SECRET'" \
    -d "client_id=book-service"
  ')

ACCESS_TOKEN=$(echo $ACCESS_TOKEN_FULL | jq -r .access_token)
echo $ACCESS_TOKEN

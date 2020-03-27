#!/usr/bin/env bash

helm delete --namespace dev my-mysql
helm delete --namespace dev my-mongodb
helm delete --namespace dev my-keycloak
helm delete --namespace dev my-postgres
helm delete --namespace dev my-kong

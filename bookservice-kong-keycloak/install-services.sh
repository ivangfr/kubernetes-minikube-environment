#!/usr/bin/env bash

helm install my-mysql --namespace dev -f helm-values/mysql-values.yaml bitnami/mysql
helm install my-mongodb --namespace dev -f helm-values/mongodb-values.yaml bitnami/mongodb
helm install my-postgres --namespace dev -f helm-values/postgres-values.yaml bitnami/postgresql

sleep 20

helm install my-keycloak --namespace dev -f helm-values/keycloak-values.yaml codecentric/keycloak
helm install my-kong --namespace dev -f helm-values/kong-values.yaml kong/kong

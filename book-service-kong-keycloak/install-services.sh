#!/usr/bin/env bash

helm install my-mysql --namespace dev --values helm-values/mysql-values.yaml bitnami/mysql
helm install my-mongodb --namespace dev --values helm-values/mongodb-values.yaml bitnami/mongodb
helm install my-postgres --namespace dev --values helm-values/postgres-values.yaml bitnami/postgresql

sleep 20

helm install my-keycloak --namespace dev --values helm-values/keycloak-values.yaml codecentric/keycloakx
helm install my-kong --namespace dev --values helm-values/kong-values.yaml kong/kong

#!/usr/bin/env bash

helm install my-mysql -n dev -f helm-values/mysql-values.yaml stable/mysql
helm install my-mongodb -n dev -f helm-values/mongodb-values.yaml bitnami/mongodb
helm install my-postgres -n dev -f helm-values/postgres-values.yaml bitnami/postgresql

sleep 20

helm install my-keycloak -n dev -f helm-values/keycloak-values.yaml codecentric/keycloak
helm install my-kong -n dev -f helm-values/kong-values.yaml kong/kong

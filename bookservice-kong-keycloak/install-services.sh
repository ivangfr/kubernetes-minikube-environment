#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set imageTag=5.7.28 \
--set mysqlDatabase=keycloak \
--set mysqlRootPassword=root-password \
--set mysqlUser=keycloak \
--set mysqlPassword=keycloak \
--set persistence.enabled=false \
stable/mysql

helm install my-mongodb \
--namespace dev \
--set image.tag=4.2.1 \
--set image.pullPolicy=IfNotPresent \
--set usePassword=false \
--set persistence.enabled=false \
stable/mongodb

helm install my-postgres \
--namespace dev \
--set image.tag=12.1.0 \
--set image.pullPolicy=IfNotPresent \
--set postgresqlDatabase=kong \
--set postgresqlUsername=kong \
--set postgresqlPassword=kong \
--set persistence.enabled=false \
stable/postgresql

sleep 20

helm install my-keycloak \
--namespace dev \
--set keycloak.image.tag=6.0.1 \
--set keycloak.username=admin \
--set keycloak.password=admin \
--set keycloak.service.type=NodePort \
--set keycloak.persistence.dbVendor=mysql \
--set keycloak.persistence.dbHost=my-mysql \
--set keycloak.persistence.dbPort=3306 \
--set keycloak.persistence.dbName=keycloak \
--set keycloak.persistence.dbUser=keycloak \
--set keycloak.persistence.dbPassword=keycloak \
codecentric/keycloak

helm install my-kong \
--namespace dev \
--set image.tag=1.4.0 \
--set env.database=postgres \
--set env.pg_host=my-postgres-postgresql \
--set env.pg_database=kong \
--set env.pg_user=kong \
--set env.pg_password=kong \
--set admin.useTLS=false \
--set readinessProbe.httpGet.scheme=HTTP \
--set livenessProbe.httpGet.scheme=HTTP \
stable/kong

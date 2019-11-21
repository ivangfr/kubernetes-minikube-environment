#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set imageTag=5.7.28 \
--set mysqlDatabase=authorbookdb \
--set mysqlRootPassword=secret \
--set persistence.enabled=false \
stable/mysql

helm install my-mongodb \
--namespace dev \
--set image.tag=4.2.1 \
--set image.pullPolicy=IfNotPresent \
--set usePassword=false \
--set persistence.enabled=false \
stable/mongodb

kubectl apply --namespace dev -f yaml-files/zipkin-deployment.yaml

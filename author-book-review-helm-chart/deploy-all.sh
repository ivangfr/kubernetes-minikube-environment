#!/usr/bin/env bash

helm install \
--namespace dev \
--name my-mysql \
--set imageTag=5.7.28 \
--set mysqlDatabase=authorbookdb \
--set mysqlRootPassword=secret \
--set persistence.enabled=false \
stable/mysql

helm install \
--namespace dev \
--name my-mongodb \
--set image.tag=4.2.1 \
--set image.pullPolicy=IfNotPresent \
--set usePassword=false \
--set persistence.enabled=false \
stable/mongodb

kubectl apply -f yaml-files/zipkin-deployment.yaml --namespace=dev
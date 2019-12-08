#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set imageTag=5.7.28 \
--set mysqlDatabase=authorbookdb \
--set mysqlUser=authorbookuser \
--set mysqlPassword=authorbookpass \
--set mysqlRootPassword=secret \
--set persistence.enabled=false \
stable/mysql

helm install my-mongodb \
--namespace dev \
--set image.tag=4.2.1 \
--set image.pullPolicy=IfNotPresent \
--set mongodbDatabase=bookreviewdb \
--set mongodbUsername=bookreviewuser \
--set mongodbPassword=bookreviewpass \
--set mongodbRootPassword=secret \
--set persistence.enabled=false \
stable/mongodb

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

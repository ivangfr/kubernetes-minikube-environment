#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set image.tag=8.0.21-debian-10-r9 \
--set db.name=authorbookdb \
--set db.user=authorbookuser \
--set db.password=authorbookpass \
--set root.password=root-password \
--set master.persistence.enabled=false \
--set slave.replicas=0 \
bitnami/mysql

helm install my-mongodb \
--namespace dev \
--set image.tag=4.2.7-debian-10-r7 \
--set image.pullPolicy=IfNotPresent \
--set mongodbDatabase=bookreviewdb \
--set mongodbUsername=bookreviewuser \
--set mongodbPassword=bookreviewpass \
--set mongodbRootPassword=secret \
--set persistence.enabled=false \
bitnami/mongodb

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

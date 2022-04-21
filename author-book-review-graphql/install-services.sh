#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set image.tag=8.0.28-debian-10-r72 \
--set auth.database=authorbookdb \
--set auth.username=authorbookuser \
--set auth.password=authorbookpass \
--set auth.rootPassword=root-password \
--set primary.persistence.enabled=false \
--set secondary.replicaCount=0 \
bitnami/mysql

helm install my-mongodb \
--namespace dev \
--set image.tag=5.0.7-debian-10-r4 \
--set auth.database=bookreviewdb \
--set auth.username=bookreviewuser \
--set auth.password=bookreviewpass \
--set auth.rootPassword=secret \
--set persistence.enabled=false \
bitnami/mongodb

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

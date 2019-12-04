#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set imageTag=5.7.28 \
--set mysqlDatabase=userdb \
--set mysqlRootPassword=secret \
--set persistence.enabled=false \
stable/mysql

helm install my-cassandra \
--namespace dev \
--set imageTag=3.11.5 \
--set config.cluster_size=1 \
--set persistence.enabled=false \
incubator/cassandra

helm install my-kafka \
--namespace dev \
--set imageTag=5.3.1 \
--set replicas=1 \
incubator/kafka

helm install my-kafka-manager \
--namespace dev \
--set image.tag=2.0.0.2 \
--set service.type=NodePort \
--set zkHosts=my-kafka-zookeeper:2181 \
stable/kafka-manager

#helm install my-schema-registry \
#--namespace dev \
#--set imageTag=5.3.1 \
#incubator/schema-registry

#helm install my-schema-registry-ui \
#--namespace dev \
#--set image.tag=0.9.5 \
#schema-registry-ui

helm install my-prometheus-operator \
--namespace dev \
--set prometheus.prometheusSpec.serviceMonitorNamespaceSelector.any=true \
--set prometheus.service.type=NodePort \
--set grafana.service.type=NodePort \
stable/prometheus-operator

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

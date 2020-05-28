#!/usr/bin/env bash

helm install my-mysql \
--namespace dev \
--set image.tag=8.0.20-debian-10-r29 \
--set root.password=secret \
--set db.name=userdb \
--set master.persistence.enabled=false \
--set slave.replicas=0 \
bitnami/mysql

#helm install my-cassandra \
#--namespace dev \
#--set image.tag=3.11.6-debian-10-r35 \
#--set dbUser.forcePassword=true \
#--set dbUser.user=eventuser \
#--set dbUser.password=eventpass \
#--set persistence.enabled=false \
#bitnami/cassandra
#+++
helm install my-cassandra \
--namespace dev \
--set imageTag=3.11.6 \
--set config.cluster_size=1 \
--set persistence.enabled=false \
incubator/cassandra

helm install my-kafka \
--namespace dev \
--set image.tag=2.4.1-debian-10-r14 \
--set replicaCount=1 \
bitnami/kafka

helm install my-kafka-manager \
--namespace dev \
--set image.repository=hlebalbau/kafka-manager \
--set image.tag=3.0.0.4  \
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

#helm install my-prometheus-operator \
#--namespace dev \
#--set prometheus.image.tag=0.38.0-debian-10-r4 \
#--set prometheus.service.type=NodePort \
#--set grafana.service.type=NodePort \
#bitnami/prometheus-operator
#+++
helm install my-prometheus-operator \
--namespace dev \
--set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
--set prometheus.service.type=NodePort \
--set grafana.service.type=NodePort \
stable/prometheus-operator

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

#!/usr/bin/env bash

helm install my-mysql --namespace dev -f helm-values/mysql-values.yaml bitnami/mysql
helm install my-cassandra --namespace dev -f helm-values/cassandra-values.yaml bitnami/cassandra

helm install my-kafka --namespace dev -f helm-values/kafka-values.yaml bitnami/kafka
helm install my-kafka-manager --namespace dev -f helm-values/kafka-manager-values.yaml stable/kafka-manager

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

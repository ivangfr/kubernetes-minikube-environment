#!/usr/bin/env bash

helm install my-mysql --namespace dev --values helm-values/mysql-values.yaml bitnami/mysql
helm install my-cassandra --namespace dev --values helm-values/cassandra-values.yaml bitnami/cassandra

helm install my-kafka --namespace dev --values helm-values/kafka-values.yaml bitnami/kafka

helm install my-schema-registry --namespace dev --values helm-values/schema-registry-values.yaml bitnami/kafka

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

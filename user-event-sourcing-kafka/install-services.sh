#!/usr/bin/env bash

helm install my-mysql --namespace dev --values helm-values/mysql-values.yaml bitnami/mysql
helm install my-cassandra --namespace dev --values helm-values/cassandra-values.yaml bitnami/cassandra

helm install my-confluent --namespace dev --values helm-values/my-confluent-values.yaml confluentinc/cp-helm-charts

helm install my-zipkin --namespace dev ../my-shared-charts/zipkin

#!/usr/bin/env bash

helm install my-mysql --namespace dev -f helm-values/mysql-values.yaml bitnami/mysql

helm install my-elasticsearch --namespace dev -f helm-values/elasticsearch-values.yaml elastic/elasticsearch
helm install my-logstash --namespace dev -f helm-values/logstash-values.yaml elastic/logstash
helm install my-kibana --namespace dev -f helm-values/kibana-values.yaml elastic/kibana
helm install my-filebeat --namespace dev -f helm-values/filebeat-values.yaml elastic/filebeat

helm install my-prometheus-operator --namespace dev -f helm-values/prometheus-operator-values.yaml bitnami/prometheus-operator
helm install my-grafana --namespace dev -f helm-values/grafana-values.yaml bitnami/grafana

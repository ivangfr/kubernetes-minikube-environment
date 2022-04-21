#!/usr/bin/env bash

helm install my-mysql --namespace dev --values helm-values/mysql-values.yaml bitnami/mysql

helm install my-elasticsearch --namespace dev --values helm-values/elasticsearch-values.yaml elastic/elasticsearch
helm install my-logstash --namespace dev --values helm-values/logstash-values.yaml elastic/logstash
helm install my-kibana --namespace dev --values helm-values/kibana-values.yaml elastic/kibana
helm install my-filebeat --namespace dev --values helm-values/filebeat-values.yaml elastic/filebeat

helm install my-kube-prometheus --namespace dev --values helm-values/kube-prometheus-values.yaml bitnami/kube-prometheus

kubectl create --namespace dev secret generic grafana-datasource-secret --from-file=grafana/provisioning/datasources/datasource.yaml
kubectl create --namespace dev configmap movies-api-dashboard --from-file=grafana/provisioning/dashboards/movies-api-dashboard.json
helm install my-grafana --namespace dev --values helm-values/grafana-values.yaml bitnami/grafana

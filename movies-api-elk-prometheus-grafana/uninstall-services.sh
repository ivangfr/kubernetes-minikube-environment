#!/usr/bin/env bash

helm delete --namespace dev my-mysql

helm delete --namespace dev my-elasticsearch
helm delete --namespace dev my-logstash
helm delete --namespace dev my-kibana
helm delete --namespace dev my-filebeat

helm delete --namespace dev my-kube-prometheus

kubectl delete secret --namespace dev grafana-datasource-secret
kubectl delete configmap --namespace dev movies-api-dashboard
helm delete --namespace dev my-grafana

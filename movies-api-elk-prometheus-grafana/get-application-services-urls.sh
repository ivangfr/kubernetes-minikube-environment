#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

MOVIES_API_PORT=$(kubectl get services --namespace dev movies-api -o go-template='{{(index .spec.ports 0).nodePort}}')
ELASTICSEARCH_PORT=$(kubectl get services --namespace dev elasticsearch-master -o go-template='{{(index .spec.ports 0).nodePort}}')
KIBANA_PORT=$(kubectl get services --namespace dev my-kibana-kibana -o go-template='{{(index .spec.ports 0).nodePort}}')
PROMETHEUS_PORT=$(kubectl get services --namespace dev my-kube-prometheus-prometheus -o go-template='{{(index .spec.ports 0).nodePort}}')
GRAFANA_PORT=$(kubectl get services --namespace dev my-grafana -o go-template='{{(index .spec.ports 0).nodePort}}')

MOVIES_API_HOST_PORT="$MINIKUBE_IP:$MOVIES_API_PORT"
ELASTICSEARCH_HOST_PORT="$MINIKUBE_IP:$ELASTICSEARCH_PORT"
KIBANA_HOST_PORT="$MINIKUBE_IP:$KIBANA_PORT"
GRAFANA_HOST_PORT="$MINIKUBE_IP:$GRAFANA_PORT"
PROMETHEUS_HOST_PORT="$MINIKUBE_IP:$PROMETHEUS_PORT"

printf "\n"
printf "%13s | %43s | %11s |\n" "Application" "URL" "Credentials"
printf "%13s + %43s + %11s |\n" "-------------" "-------------------------------------------" "-----------"
printf "%13s | %43s | %11s |\n" "movies-api" "http://$MOVIES_API_HOST_PORT/swagger-ui.html" ""
printf "%13s | %43s | %11s |\n" "elasticsearch" "http://$ELASTICSEARCH_HOST_PORT" ""
printf "%13s | %43s | %11s |\n" "kibana" "http://$KIBANA_HOST_PORT" ""
printf "%13s | %43s | %11s |\n" "grafana" "http://$GRAFANA_HOST_PORT" "admin/admin"
printf "%13s | %43s | %11s |\n" "prometheus" "http://$PROMETHEUS_HOST_PORT" ""
printf "\n"

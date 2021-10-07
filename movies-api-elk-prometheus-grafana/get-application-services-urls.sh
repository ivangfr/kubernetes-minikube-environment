#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

MOVIES_API_PORT=$(kubectl get services --namespace dev movies-api -o go-template='{{(index .spec.ports 0).nodePort}}')
ELASTICSEARCH_PORT=$(kubectl get services --namespace dev elasticsearch-master -o go-template='{{(index .spec.ports 0).nodePort}}')
KIBANA_PORT=$(kubectl get services --namespace dev my-kibana-kibana -o go-template='{{(index .spec.ports 0).nodePort}}')
PROMETHEUS_PORT=$(kubectl get services --namespace dev my-kube-prometheus-prometheus -o go-template='{{(index .spec.ports 0).nodePort}}')
GRAFANA_PORT=$(kubectl get services --namespace dev my-grafana -o go-template='{{(index .spec.ports 0).nodePort}}')

MOVIES_API_URL="$MINIKUBE_IP:$MOVIES_API_PORT"
ELASTICSEARCH_URL="$MINIKUBE_IP:$ELASTICSEARCH_PORT"
KIBANA_URL="$MINIKUBE_IP:$KIBANA_PORT"
GRAFANA_URL="$MINIKUBE_IP:$GRAFANA_PORT"
PROMETHEUS_URL="$MINIKUBE_IP:$PROMETHEUS_PORT"

printf "\n"
printf "%13s | %43s | %11s |\n" "Application" "URL" "Credentials"
printf "%13s + %43s + %11s |\n" "-------------" "-------------------------------------------" "-----------"
printf "%13s | %43s | %11s |\n" "movies-api" "http://$MOVIES_API_URL/swagger-ui.html" ""
printf "%13s | %43s | %11s |\n" "elasticsearch" "http://$ELASTICSEARCH_URL" ""
printf "%13s | %43s | %11s |\n" "kibana" "http://$KIBANA_URL" ""
printf "%13s | %43s | %11s |\n" "grafana" "http://$GRAFANA_URL" "admin/admin"
printf "%13s | %43s | %11s |\n" "prometheus" "http://$PROMETHEUS_URL" ""
printf "\n"

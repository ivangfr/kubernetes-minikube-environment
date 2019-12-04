#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

USER_SERVICE_PORT=$(kubectl get services --namespace dev user-service -o go-template='{{(index .spec.ports 0).nodePort}}')
EVENT_SERVICE_PORT=$(kubectl get services --namespace dev event-service -o go-template='{{(index .spec.ports 0).nodePort}}')
ZIPKIN_PORT=$(kubectl get services --namespace dev my-zipkin -o go-template='{{(index .spec.ports 0).nodePort}}')
PROMETHEUS_PORT=$(kubectl get services --namespace dev my-prometheus-operator-prometheus -o go-template='{{(index .spec.ports 0).nodePort}}')
GRAFANA_PORT=$(kubectl get services --namespace dev my-prometheus-operator-grafana -o go-template='{{(index .spec.ports 0).nodePort}}')
KAFKA_MANAGER_PORT=$(kubectl get services --namespace dev my-kafka-manager -o go-template='{{(index .spec.ports 0).nodePort}}')

USER_SERVICE_URL="$MINIKUBE_IP:$USER_SERVICE_PORT"
EVENT_SERVICE_URL="$MINIKUBE_IP:$EVENT_SERVICE_PORT"
GRAFANA_URL="$MINIKUBE_IP:$GRAFANA_PORT"
PROMETHEUS_URL="$MINIKUBE_IP:$PROMETHEUS_PORT"
KAFKA_MANAGER_URL="$MINIKUBE_IP:$KAFKA_MANAGER_PORT"
ZIPKIN_URL="$MINIKUBE_IP:$ZIPKIN_PORT"

printf "\n"
printf "%19s | %43s | %19s |\n" "Application" "URL" "Credentials"
printf "%19s + %43s + %19s |\n" "-------------------" "-------------------------------------------" "-------------------"
printf "%19s | %43s | %19s |\n" "user-service" "http://$USER_SERVICE_URL/swagger-ui.html" ""
printf "%19s | %43s | %19s |\n" "event-service" "http://$EVENT_SERVICE_URL/swagger-ui.html" ""
printf "%19s | %43s | %19s |\n" "grafana" "http://$GRAFANA_URL" "admin/prom-operator"
printf "%19s | %43s | %19s |\n" "prometheus" "http://$PROMETHEUS_URL" ""
printf "%19s | %43s | %19s |\n" "kafka-manager" "http://$KAFKA_MANAGER_URL" ""
printf "%19s | %43s | %19s |\n" "my-zipkin" "http://$ZIPKIN_URL" ""
printf "%19s | %43s | %19s |\n" "schema-registry-ui" "" ""
printf "\n"

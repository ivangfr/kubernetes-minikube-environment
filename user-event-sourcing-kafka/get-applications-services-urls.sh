#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

USER_SERVICE_PORT=$(kubectl get services --namespace dev user-service -o go-template='{{(index .spec.ports 0).nodePort}}')
EVENT_SERVICE_PORT=$(kubectl get services --namespace dev event-service -o go-template='{{(index .spec.ports 0).nodePort}}')
ZIPKIN_PORT=$(kubectl get services --namespace dev my-zipkin -o go-template='{{(index .spec.ports 0).nodePort}}')

USER_SERVICE_HOST_PORT="$MINIKUBE_IP:$USER_SERVICE_PORT"
EVENT_SERVICE_HOST_PORT="$MINIKUBE_IP:$EVENT_SERVICE_PORT"
ZIPKIN_HOST_PORT="$MINIKUBE_IP:$ZIPKIN_PORT"

printf "\n"
printf "%14s | %43s |\n" "Application" "URL"
printf "%14s + %43s |\n" "--------------" "-------------------------------------------"
printf "%14s | %43s |\n" "user-service" "http://$USER_SERVICE_HOST_PORT/swagger-ui.html"
printf "%14s | %43s |\n" "event-service" "http://$EVENT_SERVICE_HOST_PORT/swagger-ui.html"
printf "%14s | %43s |\n" "my-zipkin" "http://$ZIPKIN_HOST_PORT"
printf "\n"

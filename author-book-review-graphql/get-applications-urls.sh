#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

ZIPKIN_PORT=$(kubectl get services --namespace dev my-zipkin -o go-template='{{(index .spec.ports 0).nodePort}}')
AUTHOR_BOOK_API_PORT=$(kubectl get services --namespace dev author-book-api -o go-template='{{(index .spec.ports 0).nodePort}}')
BOOK_REVIEW_API_PORT=$(kubectl get services --namespace dev book-review-api -o go-template='{{(index .spec.ports 0).nodePort}}')

ZIPKIN_HOST_PORT="$MINIKUBE_IP:$ZIPKIN_PORT"
AUTHOR_BOOK_API_HOST_PORT="$MINIKUBE_IP:$AUTHOR_BOOK_API_PORT"
BOOK_REVIEW_API_HOST_PORT="$MINIKUBE_IP:$BOOK_REVIEW_API_PORT"

printf "\n"
printf "%16s | %9s | %45s |\n" "Application" "Type" "URL"
printf "%16s + %9s + %45s |\n" "----------------" "---------" "---------------------------------------------"
printf "%16s | %9s | %45s |\n" "my-zipkin" "Website" "http://$ZIPKIN_HOST_PORT"
printf "%16s | %9s | %45s |\n" "author-book-api" "Swagger" "http://$AUTHOR_BOOK_API_HOST_PORT/swagger-ui.html"
printf "%16s | %9s | %45s |\n" "author-book-api" "GraphiQL" "http://$AUTHOR_BOOK_API_HOST_PORT/graphiql"
printf "%16s | %9s | %45s |\n" "book-review-api" "GraphiQL" "http://$BOOK_REVIEW_API_HOST_PORT/graphiql"
printf "\n"

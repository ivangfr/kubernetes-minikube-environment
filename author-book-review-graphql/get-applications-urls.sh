#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

AUTHOR_BOOK_API_PORT=$(kubectl get services --namespace dev author-book-api -o go-template='{{(index .spec.ports 0).nodePort}}')
BOOK_REVIEW_API_PORT=$(kubectl get services --namespace dev book-review-api -o go-template='{{(index .spec.ports 0).nodePort}}')
ZIPKIN_PORT=$(kubectl get services --namespace dev my-zipkin -o go-template='{{(index .spec.ports 0).nodePort}}')

AUTHOR_BOOK_API_URL="$MINIKUBE_IP:$AUTHOR_BOOK_API_PORT"
BOOK_REVIEW_API_URL="$MINIKUBE_IP:$BOOK_REVIEW_API_PORT"
ZIPKIN_URL="$MINIKUBE_IP:$ZIPKIN_PORT"

printf "\n"
printf "%16s | %9s | %45s |\n" "Application" "Type" "URL"
printf "%16s + %9s + %45s |\n" "----------------" "---------" "---------------------------------------------"
printf "%16s | %9s | %45s |\n" "my-zipkin" "Website" "http://$ZIPKIN_URL"
printf "%16s | %9s | %45s |\n" "author-book-api" "Swagger" "http://$AUTHOR_BOOK_API_URL/swagger-ui.html"
printf "%16s | %9s | %45s |\n" "author-book-api" "GraphiQL" "http://$AUTHOR_BOOK_API_URL/graphiql"
printf "%16s | %9s | %45s |\n" "book-review-api" "GraphiQL" "http://$BOOK_REVIEW_API_URL/graphiql"
printf "\n"

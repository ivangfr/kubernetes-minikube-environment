#!/usr/bin/env bash

MINIKUBE_IP=$(minikube ip)

AUTHOR_BOOK_API_PORT=$(kubectl get services authorbookapi-service --namespace dev -o go-template='{{(index .spec.ports 0).nodePort}}')
BOOK_REVIEW_API_PORT=$(kubectl get services bookreviewapi-service --namespace dev -o go-template='{{(index .spec.ports 0).nodePort}}')

AUTHOR_BOOK_API_URL="$MINIKUBE_IP:$AUTHOR_BOOK_API_PORT"
BOOK_REVIEW_API_URL="$MINIKUBE_IP:$BOOK_REVIEW_API_PORT"

printf "%16s | %9s | %45s |\n" "Application" "API Type" "URL"
printf "%16s + %9s + %45s |\n" "----------------" "---------" "---------------------------------------------"
printf "%16s | %9s | %45s |\n" "author-book-api" "Swagger" "http://$AUTHOR_BOOK_API_URL/swagger-ui.html"
printf "%16s | %9s | %45s |\n" "author-book-api" "GraphiQL" "http://$AUTHOR_BOOK_API_URL/graphiql"
printf "%16s | %9s | %45s |\n" "book-review-api" "GraphiQL" "http://$BOOK_REVIEW_API_URL/graphiql"

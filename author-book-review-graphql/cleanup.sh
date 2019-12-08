#!/usr/bin/env bash

helm delete --namespace dev book-review-api
helm delete --namespace dev author-book-api

kubectl delete secrets --namespace dev author-book-api-db
kubectl delete secrets --namespace dev book-review-api-db

./uninstall-services.sh

kubectl delete -f yaml-files/dev-namespace.yaml

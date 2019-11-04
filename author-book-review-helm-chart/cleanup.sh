#!/usr/bin/env bash

kubectl apply -f yaml-files/book-review-api-deployment.yaml --namespace dev
kubectl apply -f yaml-files/author-book-api-deployment.yaml --namespace dev

helm delete --purge my-mysql my-mongodb

kubectl delete -f yaml-files/dev-namespace.yaml

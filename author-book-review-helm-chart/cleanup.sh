#!/usr/bin/env bash

helm delete book-review-api --namespace dev
helm delete author-book-api --namespace dev

helm delete my-mysql --namespace dev
helm delete my-mongodb --namespace dev

kubectl delete -f yaml-files/dev-namespace.yaml

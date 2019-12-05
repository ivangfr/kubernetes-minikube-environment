#!/usr/bin/env bash

helm delete book-review-api --namespace dev
helm delete author-book-api --namespace dev

./uninstall-services.sh

kubectl delete -f yaml-files/dev-namespace.yaml

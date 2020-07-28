#!/usr/bin/env bash

helm delete --namespace dev user-service
helm delete --namespace dev event-service

./uninstall-services.sh

kubectl delete namespace dev

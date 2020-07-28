#!/usr/bin/env bash

helm delete --namespace dev movies-api

./uninstall-services.sh

kubectl delete namespace dev

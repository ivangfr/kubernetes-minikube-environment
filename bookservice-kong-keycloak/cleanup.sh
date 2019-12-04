#!/usr/bin/env bash

./uninstall-services.sh

kubectl delete --namespace dev -f yaml-files/bookservice-deployment.yaml

kubectl delete -f yaml-files/dev-namespace.yaml

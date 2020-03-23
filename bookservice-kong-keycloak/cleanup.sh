#!/usr/bin/env bash

./uninstall-services.sh

kubectl delete --namespace dev -f deployment-files/bookservice-deployment.yaml

kubectl delete namespace dev

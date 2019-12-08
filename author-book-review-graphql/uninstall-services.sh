#!/usr/bin/env bash

helm delete --namespace dev my-zipkin
helm delete --namespace dev my-mysql
helm delete --namespace dev my-mongodb

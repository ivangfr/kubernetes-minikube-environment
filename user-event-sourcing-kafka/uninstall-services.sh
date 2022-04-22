#!/usr/bin/env bash

helm delete --namespace dev my-mysql
helm delete --namespace dev my-cassandra
helm delete --namespace dev my-confluent
helm delete --namespace dev my-zipkin

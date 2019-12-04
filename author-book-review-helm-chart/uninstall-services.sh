#!/usr/bin/env bash

helm delete my-zipkin --namespace dev
helm delete my-mysql --namespace dev
helm delete my-mongodb --namespace dev

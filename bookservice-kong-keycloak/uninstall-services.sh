#!/usr/bin/env bash

helm delete -n dev my-mysql
helm delete -n dev my-mongodb
helm delete -n dev my-keycloak
helm delete -n dev my-postgres
helm delete -n dev my-kong

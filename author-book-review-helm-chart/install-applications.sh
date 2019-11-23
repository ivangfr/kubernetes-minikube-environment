#!/usr/bin/env bash

helm install book-review-api --namespace dev ./my-charts/book-review-api
helm install author-book-api --namespace dev ./my-charts/author-book-api

# Kubernetes

## TODO: add Persistent Volume
see https://steemit.com/programming/@clutteredcode/docker-kubernetes-series-part2-mongodb

```
eval $(minikube docker-env)

gradle build docker

kubectl apply -f kubernetes/mongodb-deployment.yaml

kubectl apply -f kubernetes/bookservice-deployment.yaml
```
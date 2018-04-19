# Kubernetes

```
eval $(minikube docker-env)

gradle build docker

kubectl apply -f kubernetes/mysql-deployment.yaml
kubectl apply -f kubernetes/keycloak-deployment.yaml

kubectl apply -f kubernetes/postgres-kong-deployment.yaml
kubectl apply -f kubernetes/kong-migration-job.yaml
kubectl apply -f kubernetes/kong-deployment.yaml

kubectl apply -f kubernetes/mongodb-deployment.yaml
kubectl apply -f kubernetes/bookservice-deployment.yaml
```
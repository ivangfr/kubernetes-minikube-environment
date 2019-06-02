# `author-book-review-helm-chart`

The goal of this project is create Helm Charts for the spring-boot applications
[`author-book-api` and `book-review-api`](https://github.com/ivangfr/springboot-graphql-databases). Then, we will use
the charts to install those applications in [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)). As `author-book-api` uses `MySQL` as storage
and `book-review-api` uses `MongoDB`, those databases will also be installed using their Helm Charts available at
https://github.com/helm/charts/tree/master/stable.

## Prerequisites

Clone `springboot-graphql-databases` project
```
git clone https://github.com/ivangfr/springboot-graphql-databases.git
```

## Start Minikube

First of all, let's start Minikube
```
minikube start
```

## Use Minikube Docker Daemon

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker Daemon.
For it, run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```
> When Minikube host won't be used anymore, you can undo this change by running   
> ```
> eval $(minikube docker-env -u)
> ```

## Helm

To initialize `Helm` run the command below
```
helm init --service-account default
```
> Note. Wait a few seconds so that `tiller` get ready. The following error will be throw if `tiller` is not ready yet.
> ```
> Error: could not find a ready tiller pod
> ```

## Build Docker Images

- Go to `springboot-graphql-databases` root folder

- Build `author-book-api` docker image
```
./mvnw clean package dockerfile:build -DskipTests --projects author-book-api
```

- Build `book-review-api` docker image
```
./mvnw clean package dockerfile:build -DskipTests --projects book-review-api
```

- You can check that the microservices docker images were created and are present among other `k8s` images by typing
```
docker images
```

## Namespaces

- List all namespaces
```
kubectl get namespaces
```

- Create a new namespace called `dev`
```
kubectl apply -f yaml-files/dev-namespace.yaml
```

## Deployments

- Go to `kubernetes-environment/author-book-review-helm-chart` folder

- Install `MySQL` using its [Helm Chart](https://github.com/kubernetes/charts/tree/master/stable/mysql)
```
helm install \
--namespace dev \
--name mysql \
--set imageTag=5.7.25 \
--set mysqlDatabase=authorbookdb \
--set mysqlRootPassword=secret \
stable/mysql
```

- Install `MongoDB` using its [Helm Chart](https://github.com/helm/charts/tree/master/stable/mongodb)
```
helm install \
--namespace dev \
--name mongodb \
--set imageTag=4.0.8 \
--set usePassword=false \
stable/mongodb
```

- Deploy `Zipkin` using `YAML` file
```
kubectl apply -f yaml-files/zipkin-deployment.yaml --namespace=dev
```

- Deploy `author-book-api` using `YAML` file
```
kubectl apply -f yaml-files/author-book-api-deployment.yaml --namespace=dev
```

- Deploy `book-review-api` using `YAML` file
```
kubectl apply -f yaml-files/book-review-api-deployment.yaml --namespace=dev
```

## Ingress (NOT WORKING)

- Enable Ingress
```
minikube addons enable ingress
```

- Deploy Ingress
```
kubectl apply -f yaml-files/apps-ingress.yaml --namespace=dev
```

## Microservice Links

| Microservice | API Type | URL |
| ------------ | -------- | --- |
| author-book-api | Swagger  | http://$MINIKUBE_IP:$AUTHOR_BOOK_API_PORT/swagger-ui.html |
| author-book-api | GraphiQL | http://$MINIKUBE_IP:$AUTHOR_BOOK_API_PORT/graphiql |
| book-review-api | GraphiQL | http://$MINIKUBE_IP:$BOOK_REVIEW_API_PORT/graphiql |

For more information about how to use the microservice's endpoints please refer to
https://github.com/ivangfr/springboot-graphql-databases 

## Shutdown

- The commands below will delete everything deployed in `dev` namespace
```
kubectl delete -f yaml-files/dev-namespace.yaml
helm delete --purge mysql mongodb
```

- The following command shuts down the Minikube Virtual Machine, but preserves all cluster state and data. Starting the
cluster again will restore it to it’s previous state.
```
minikube stop
```

- The command shuts down and deletes the Minikube Virtual Machine. No data or state is preserved.
```
minikube delete
```

## TODO

- understand how namespace in Helm works;
- helmfy zipkin, author-book-api and book-review-api;
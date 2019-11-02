# `author-book-review-helm-chart`

The goal of this project is create Helm Charts for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
applications [`author-book-api` and `book-review-api`](https://github.com/ivangfr/springboot-graphql-databases). Then,
we will use the charts to install those applications in [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)). As `author-book-api` uses `MySQL` as storage
and `book-review-api` uses `MongoDB`, those databases will also be installed using their Helm Charts available at
https://github.com/helm/charts/tree/master/stable.

## Prerequisites

Clone `springboot-graphql-databases` project
```
git clone https://github.com/ivangfr/springboot-graphql-databases.git
```

## Start Minikube and Helm

First of all, start `Minikube` and `Helm` as explained at [Start Minikube and Helm](https://github.com/ivangfr/kubernetes-environment#start-minikube-and-helm)

## Build Docker Images

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon.

For it, open a terminal and run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```

Then, inside `springboot-graphql-databases` root folder, run the following `./mvnw` commands to build `book-review-api`
and `author-book-api` docker images

- Build `book-review-api` docker image
```
./mvnw clean package dockerfile:build -DskipTests --projects book-review-api
```

- Build `author-book-api` docker image
```
./mvnw clean package dockerfile:build -DskipTests --projects author-book-api
```

Once it is finished, run the command below to check that `book-review-api` and `author-book-api` docker images were
created and are present among other `k8s` images
```
docker images
```

As `Minikube` host won't be used anymore, you can undo this change by running   
```
eval $(minikube docker-env -u)
```

## Namespaces

To list all namespaces run
```
kubectl get namespaces
```

Let's create a new namespace called `dev`. For it, in a terminal and inside `kubernetes-environment/author-book-review-helm-chart`
folder, run the following command
```
kubectl apply -f yaml-files/dev-namespace.yaml
```

## Deployments

Inside `kubernetes-environment/author-book-review-helm-chart` folder, run the following script
```
./install-services.sh
```

It will install `MySQL`, `MongoDB` and `Zipkin`. This process can take some time (pulling docker images, starting
services, etc). You can check the status progress by running
```
kubectl get pods --namespace dev
```

## Deploy book-review-api and author-book-api

In `kubernetes-environment/author-book-review-helm-chart` folder, run the following commands

- Deploy `book-review-api` using `YAML` file
```
kubectl apply -f yaml-files/book-review-api-deployment.yaml --namespace dev
```

- Deploy `author-book-api` using `YAML` file
```
kubectl apply -f yaml-files/author-book-api-deployment.yaml --namespace dev
```

## Applications Urls

To get `author-book-api` and `book-review-api` urls, run the script below
```
./get-applications-urls.sh
```

You should see something similar to
```
     Application | API Type |                                         URL |
---------------- | -------- |  ------------------------------------------ |
 author-book-api |  Swagger | http://192.168.99.105:31319/swagger-ui.html |
 author-book-api | GraphiQL |        http://192.168.99.105:31319/graphiql |
 book-review-api | GraphiQL |        http://192.168.99.105:31781/graphiql |
```

For more information about how to use the application's endpoints please refer to
https://github.com/ivangfr/springboot-graphql-databases#how-to-use-graphiql

## Cleanup

The script below will delete all deployments
```
./cleanup.sh
```

## TODO

- Helmfy `Zipkin`, `author-book-api` and `book-review-api`;
- [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) for `author-book-api` and `book-review-api` ();
- Understand how namespace in Helm works;
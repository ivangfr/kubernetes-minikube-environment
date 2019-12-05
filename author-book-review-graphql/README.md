# `author-book-review-graphql`

The goal of this project is to create `Helm Charts` for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications [`author-book-api` and `book-review-api`](https://github.com/ivangfr/springboot-graphql-databases). Then, we will use the charts to install those applications in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)). As `author-book-api` uses `MySQL` as storage and `book-review-api` uses `MongoDB`, those databases will also be installed using their `Helm Charts` available at https://github.com/helm/charts.

## Clone example repository

Clone [`springboot-graphql-databases`](https://github.com/ivangfr/springboot-graphql-databases) repository. For it, open a terminal and run
```
git clone https://github.com/ivangfr/springboot-graphql-databases.git
```

## Start Minikube

First of all, start `Minikube` as explained at [Start Minikube](https://github.com/ivangfr/kubernetes-environment#start-minikube)

## Build Docker Images

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon.

For it, open a terminal and run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```

Then, inside `springboot-graphql-databases` root folder, run the following `./mvnw` commands to build `book-review-api` and `author-book-api` docker images
```
./mvnw clean package dockerfile:build -DskipTests --projects book-review-api
./mvnw clean package dockerfile:build -DskipTests --projects author-book-api
```

Once it is finished, run the command below to check that `book-review-api` and `author-book-api` docker images were created and are present among other `k8s` images
```
docker images
```

As `Minikube` host won't be used anymore, you can undo this change by running   
```
eval $(minikube docker-env -u)
```

## Create a namespace

Let's create a new namespace called `dev`. For it, in a terminal and inside `kubernetes-environment/author-book-review-graphql`folder, run the following command
```
kubectl apply -f yaml-files/dev-namespace.yaml
```
> To delete run
> ```
> kubectl delete -f yaml-files/dev-namespace.yaml
> ```

To list all namespaces run
```
kubectl get namespaces
```

## Install services

In a terminal and, inside `kubernetes-environment/author-book-review-graphql` folder, run the following script
```
./install-services.sh
```
> To uninstall run
> ```
> ./uninstall-services.sh
> ```

It will install `MySQL`, `MongoDB` and `Zipkin`. This process can take some time (pulling docker images, starting services, etc). You can check the progress status of the services by running
```
kubectl get pods --namespace dev
```

## Install applications

In a terminal and inside `kubernetes-environment/author-book-review-graphql`, run the following commands to install the `Helm Chart` of `book-review-api` and `author-book-api`.

In order to install `book-review-api` run
```
helm install book-review-api --namespace dev ./my-charts/book-review-api
```
> To delete run
> ```
> helm delete --namespace dev book-review-api
> ```

To install `author-book-api` run
```
helm install author-book-api --namespace dev ./my-charts/author-book-api
```
> To delete run
> ```
> helm delete --namespace dev author-book-api
> ```

## Applications URLs

In a terminal and, inside `kubernetes-environment/author-book-review-graphql` folder, run the command below to get `zipkin`, `author-book-api` and `book-review-api` URLs
```
./get-applications-urls.sh
```

You should see something like
```
     Application |      Type |                                           URL |
---------------- + --------- + --------------------------------------------- |
       my-zipkin |   Website |                   http://192.168.99.107:32075 |
 author-book-api |   Swagger |   http://192.168.99.107:32130/swagger-ui.html |
 author-book-api |  GraphiQL |          http://192.168.99.107:32130/graphiql |
 book-review-api |  GraphiQL |          http://192.168.99.107:32583/graphiql |
```

For more information about how to use the application's endpoints please refer to https://github.com/ivangfr/springboot-graphql-databases#how-to-use-graphiql

## Cleanup

In a terminal and, inside `kubernetes-environment/author-book-review-graphql` folder, run the script below to uninstall all services, applications and `dev` namespace
```
./cleanup.sh
```
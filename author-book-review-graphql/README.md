# kubernetes-environment
## `> author-book-review-graphql`

The goal of this project is to create `Helm Charts` for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications [`author-book-api` and `book-review-api`](https://github.com/ivangfr/springboot-graphql-databases). Then, we will use the charts to install those applications in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)). As `author-book-api` uses `MySQL` as storage and `book-review-api` uses `MongoDB`, those databases will also be installed using their `Helm Charts` available at https://github.com/helm/charts.

## Clone example repository

Clone [`springboot-graphql-databases`](https://github.com/ivangfr/springboot-graphql-databases) repository. For it, open a terminal and run
```
git clone https://github.com/ivangfr/springboot-graphql-databases.git
```

## Start Minikube

First of all, start `Minikube` as explained in [Start Minikube](https://github.com/ivangfr/kubernetes-environment#start-minikube)

## Build Docker Images

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon. Below are the steps

- In a terminal, navigate to `springboot-graphql-databases` root folder

- Set `Minikube` host
  ```
  eval $(minikube docker-env)
  ```

- Build application's docker images
  ```
  ./build-apps.sh
  ```

- \[Optional\] Check whether `book-review-api` and `author-book-api` docker images were created
  ```
  docker images
  ```

- Get back to Host machine Docker Daemon   
  ```
  eval $(minikube docker-env -u)
  ```

## Create a namespace

- In a terminal, run the following command to create a new namespace called `dev`
  ```
  kubectl create namespace dev
  ```
  > To delete run
  > ```
  > kubectl delete namespace dev
  > ```

- \[Optional\] To list all namespaces run
  ```
  kubectl get namespaces
  ```

## Install services

- In a terminal, navigate to `kubernetes-environment/author-book-review-graphql` folder

- To install the services, run the script below
  ```
  ./install-services.sh
  ```
  > To uninstall run
  > ```
  > ./uninstall-services.sh
  > ```

  It will install `MySQL`, `MongoDB` and `Zipkin`. This process can take some time (pulling docker images, starting services, etc).
  
- Check the status/progress of the service installation
  ```
  kubectl get pods --namespace dev
  ```

## Create application database secrets

- In a terminal, run the command below to create a secret used by `book-review-api` to connect to `MongoDB`
  ```
  kubectl create secret --namespace dev generic book-review-api-db \
   --from-literal=username=bookreviewuser --from-literal=password=bookreviewpass
  ```
  > To delete run
  > ```
  > kubectl delete secrets --namespace dev book-review-api-db
  > ```

- Run the following command to create a secret used by `author-book-api` to connect to `MySQL`
  ```
  kubectl create secret --namespace dev generic author-book-api-db \
   --from-literal=username=authorbookuser --from-literal=password=authorbookpass
  ```
  > To delete run
  > ```
  > kubectl delete secrets --namespace dev author-book-api-db
  > ```

- \[Optional\] To list the secrets present in `dev` namespace run
  ```
  kubectl get secrets --namespace dev
  ```

- \[Optional\] To get more information about `book-review-api-db` secret run
  ```
  kubectl get secrets --namespace dev book-review-api-db -o yaml
  ```

## Install applications

- In a terminal, make sure you are in `kubernetes-environment/author-book-review-graphql` folder

- Install `book-review-api`
  ```
  helm install book-review-api --namespace dev ./my-charts/book-review-api
  ```
  > To delete run
  > ```
  > helm delete --namespace dev book-review-api
  > ```

- Install `author-book-api`
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

- In a terminal, make sure you are in `kubernetes-environment/author-book-review-graphql` folder

- Run the script below to uninstall all services, applications and `dev` namespace.
  ```
  ./cleanup.sh
  ```

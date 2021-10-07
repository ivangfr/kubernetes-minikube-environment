# kubernetes-minikube-environment
## `> author-book-review-graphql`

The goal of this example is to create `Helm Charts` for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications [`author-book-api` and `book-review-api`](https://github.com/ivangfr/springboot-graphql-databases). Then, these charts will be used to install `author-book-api` and `book-review-api` in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)).

As `author-book-api` uses `MySQL` as storage and `book-review-api` uses `MongoDB`, these databases will also be installed using their `Helm Charts`.

## Clone example repository

- Open a terminal

- Run the following command to clone [`springboot-graphql-databases`](https://github.com/ivangfr/springboot-graphql-databases)
  ```
  git clone https://github.com/ivangfr/springboot-graphql-databases.git
  ```

## Start Minikube

First, start `Minikube` as explained in [Start Minikube](https://github.com/ivangfr/kubernetes-minikube-environment#start-minikube)

## Build Docker Images

- In a terminal, navigate to `springboot-graphql-databases` root folder

- Set `Minikube` host
  ```
  eval $(minikube docker-env)
  ```

- Build `author-book-api` and `book-review-api` Docker images so that we don't need to push them to Docker Registry. To do it, run the following script
  ```
  ./docker-build.sh
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

- In a terminal, navigate to `kubernetes-minikube-environment/author-book-review-graphql` folder

- To install the services, run the script below
  ```
  ./install-services.sh
  ```
  > To uninstall run
  > ```
  > ./uninstall-services.sh
  > ```

  It will install `MySQL`, `MongoDB` and `Zipkin`. This process will take time because it involves pulling service's docker images and starting them.
  
- Watch the status/progress of the service's installation
  ```
  kubectl get pods --namespace dev --watch
  ```
  > To stop watching, press `Ctrl+C`

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

- In a terminal, make sure you are in `kubernetes-minikube-environment/author-book-review-graphql` folder

- Install `book-review-api`
  ```
  helm install book-review-api --namespace dev my-charts/book-review-api
  ```
  > To delete run
  > ```
  > helm delete --namespace dev book-review-api
  > ```

- Install `author-book-api`
  ```
  helm install author-book-api --namespace dev my-charts/author-book-api
  ```
  > To delete run
  > ```
  > helm delete --namespace dev author-book-api
  > ```

## Applications URLs

- In a terminal, make sure you are inside `kubernetes-minikube-environment/author-book-review-graphql` folder

- Run the command below to get `zipkin`, `author-book-api` and `book-review-api` URLs
  ```
  ./get-applications-urls.sh
  ```

- For more information about how to use the application's endpoints, refer to https://github.com/ivangfr/springboot-graphql-databases#how-to-use-graphiql

## Cleanup

- In a terminal, make sure you are in `kubernetes-minikube-environment/author-book-review-graphql` folder

- Run the script below to uninstall all services, applications and `dev` namespace.
  ```
  ./cleanup.sh
  ```

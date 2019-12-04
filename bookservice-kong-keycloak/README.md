# `bookservice-kong-keycloak`

The goal of this project is to run inside [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube)):
[`book-service`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak)
([`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) application),
[`Keycloak`](https://www.keycloak.org) (authentication and authorization service) and
[`Kong`](https://konghq.com) (gateway service).

## Clone example repository

Clone [`springboot-testing-mongodb-keycloak`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak) repository.
For it, open a terminal and run
```
git clone https://github.com/ivangfr/springboot-testing-mongodb-keycloak.git
```

### book-service

`book-service` is a `Spring Boot` Web Java application that exposes some endpoints to manage books. Once deployed in
`Kubernetes` cluster, it won't be exposed to outside, i.e, it won't be possible to be accessed directly from the host
machine. In order to bypass it, we are going to use `Kong` as a gateway service. So, to access `book-service`, you will
have to call `Kong` REST API and then, `Kong` will redirect the request to `book-service`. Furthermore, the plugin
`Rate Limiting` will be installed in `Kong`. It will be configured to just allow 5 requests a minute to any
`book-service` endpoints.

Besides, `book-service` implements `Keycloak` security configuration. The endpoints related to _"managing books"_, like
create book (`POST /api/books`), update book (`PATCH /api/books/{id}`) and delete book (`DELETE /api/books/{id}`) will
require a `Bearer JWT Access Token`.

## Start Minikube

First of all, start `Minikube` as explained at [Start Minikube](https://github.com/ivangfr/kubernetes-environment#start-minikube)

## Build Docker Image

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon.

For it, open a terminal and run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```

Then, inside `springboot-testing-mongodb-keycloak` root folder, run the following command
```
./gradlew book-service:clean book-service:build docker -x test -x integrationTest
``` 

Once it is finished, run the command below to check that the `book-service` docker image was created and is present
among other `k8s` docker images by running
```
docker images
```

As `Minikube` host won't be used anymore, you can undo this change by running   
```
eval $(minikube docker-env -u)
```

## Create a namespace

Let's create a new namespace called `dev`. For it, in a terminal and inside
`kubernetes-environment/bookservice-kong-keycloak`folder, run the following command
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

In a terminal and inside `kubernetes-environment/bookservice-kong-keycloak` folder, run the following script
```
./install-services.sh
```
> To uninstall run
> ```
> ./uninstall-services.sh
> ```

It will install `MySQL`, `Postgres`, `MongoDB` `Kong` and `Keycloak`. It can take some time (pulling docker images,
starting services, etc). You can check the status progress by running
```
kubectl get pods
```

## Services URLs

In a terminal and inside `kubernetes-environment/bookservice-kong-keycloak` folder, run the following script. It will
get the exposed `Kong` and `Keycloak` URLs.
```
./get-services-urls.sh
``` 

**IMPORTANT**: Copy the output and run it in a terminal. It will export `Kong` and `Keycloak` URLs to environment
variables. Those environment variables will be used on the next steps.

## Configure Keycloak

Before start, check if `Keycloak` is ready by running the command below.
```
kubectl get pods --namespace dev
```
The column `READY` must show `1/1`. If it is showing `0/1`, wait a little bit.

There are two ways to configure `Keycloak`: running a script or using Keycloak website

### Running script
 
In a terminal and inside `springboot-testing-mongodb-keycloak` root folder, run the following script
```
./init-keycloak.sh $KEYCLOAK_URL
```

In the end, `BOOK_SERVICE_CLIENT_SECRET` will be printed. It will be used on the next steps.

### Using Keycloak website

Open `Keyloak` website
```
minikube service my-keycloak-http
```

Add `realm`, `client`, `client-roles` and `user` as explained [`here`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak#using-keycloak-website)

## Install book-service

In a terminal and inside `kubernetes-environment/bookservice-kong-keycloak` folder, run the following command to
deploy `book-service`
```
kubectl apply --namespace dev -f yaml-files/bookservice-deployment.yaml
```
> To delete run
> ```
> kubectl delete --namespace dev -f yaml-files/bookservice-deployment.yaml
> ```

## Configuring Kong

1. Add service `book-service`
   ```
   curl -i -X POST http://$KONG_ADMIN_URL/services/ \
     -d 'name=book-service' \
     -d 'protocol=http' \
     -d 'host=bookservice-service' \
     -d 'port=8080'
   ```

1. Add `book-service` route
   ```
   curl -i -X POST http://$KONG_ADMIN_URL/services/book-service/routes/ \
     -d "protocols[]=http" \
     -d "hosts[]=book-service" \
     -d "strip_path=false"
   ```

1. In order to test the added route, we will use `GET /actuator/health`
   ```
   curl -i http://$KONG_PROXY_URL/actuator/health -H 'Host: book-service'
   ```
   It should return
   ```
   HTTP/1.1 200
   {
     "status": "UP",
     "details": {
       "diskSpace": {
         "status": "UP",
         "details": {
         	...
         }
       },
       "mongo": {
         "status": "UP",
         "details": {
           ...
         }
       }
     }
   }
   ```

1. Add Rate Limiting plugin to `book-service` service
   ```
   curl -X POST http://$KONG_ADMIN_URL/services/book-service/plugins \
     -d "name=rate-limiting"  \
     -d "config.minute=10"
   ```
   
1. Make some calls to
   ```
   curl -i http://$KONG_PROXY_URL/actuator/health -H 'Host: book-service'
   ```
   After exceeding 10 calls in a minute, you should see
   ```
   HTTP/1.1 429 Too Many Requests
   {"message":"API rate limit exceeded"}
   ```

## Final test

1. Call `GET /api/books` endpoint
   ```
   curl -i http://$KONG_PROXY_URL/api/books -H 'Host: book-service'
   ```
   It should return
   ```
   HTTP/1.1 200
   []
   ```

1. Call `POST /api/books` endpoint without access token
   ```
   curl -i -X POST http://$KONG_PROXY_URL/api/books -H 'Host: book-service' \
     -H "Content-Type: application/json" \
     -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
   ```
   It should return
   ```
   HTTP/1.1 302
   ```

1. Get access token from Keycloak

   - In a terminal, export the `Client Secret` generated by `Keycloak` to `book-service` at [Configure Keycloak](#configure-keycloak)
     ```
     export BOOK_SERVICE_CLIENT_SECRET=...
     ```
   
   - In `kubernetes-environment/bookservice-kong-keycloak` folder, run the script below to get the access token
     ```
     BEARER_MY_ACCESS_TOKEN=$(./get-access-token.sh $BOOK_SERVICE_CLIENT_SECRET)
     ```
   
   - To see the access token value run
     ```
     echo $BEARER_MY_ACCESS_TOKEN
     ```

1. Call `POST /api/books` endpoint informing the access token
   ```
   curl -i -X POST http://$KONG_PROXY_URL/api/books -H 'Host: book-service' \
     -H "Authorization: $BEARER_MY_ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
   ```
   It should return
   ```
   HTTP/1.1 201 
   {
     "id":"6d1270d5-716f-46b1-9a9d-e152f62464aa",
     "title":"java 8",
     "authorName":"ivan",
     "price":10.5
   }
   ```

## Cleanup

In a terminal and, inside `kubernetes-environment/author-book-review-helm-chart` folder, run the script below to uninstall
all services, `book-service` application and `dev` namespace.
```
./cleanup.sh
```

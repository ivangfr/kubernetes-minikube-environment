# `bookservice-kong-keycloak`

The goal of this project is to run inside [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube)):
[`book-service`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak)
([`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) application),
[`Keycloak`](https://www.keycloak.org) (authentication and authorization service) and
[`Kong`](https://konghq.com) (gateway service).

## Prerequisites

Clone [`springboot-testing-mongodb-keycloak`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak) project
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

## Deployments

Inside `kubernetes-environment/bookservice-kong-keycloak` folder, run the following script
```
./install-services.sh
```

It will install `MySQL`, `Postgres`, `MongoDB` `Kong` and `Keycloak`. It can take some time (pulling docker images,
starting services, etc). You can check the status progress by running
```
kubectl get pods
```

> Note. If `Keycloak` is not getting up, run the script below. It will redeploy `MySQL` and `Keycloak`.	
> ```	
> ./redinstall-mysql-keycloak.sh	
> ```

## Services Urls

Run the following script. It will get the exposed `Kong` and `Keycloak` urls.
```
./get-services-urls.sh
``` 

**Copy the output and run it in a terminal. It will export `Kong` and `Keycloak` urls to environment variables.
Those environment variables will be used on the next steps.**

## Configure Keycloak

Before start, check if `Keycloak` is ready by running `kubectl get pods`. The column `READY` must show `1/1`. If it is
showing `0/1`, wait a little bit.

### Automatically running script
 
In a terminal, go to `springboot-testing-mongodb-keycloak` root folder and run the following script
```
./init-keycloak.sh $KEYCLOAK_URL
```

In the end, the script prints the `BOOKSERVICE_CLIENT_SECRET`. It will be used on the next steps.

### Manually using Keycloak UI

Open `Keyloak UI`
```
minikube service my-keycloak-http
```

Add `realm`, `client`, `client-roles` and `user` as explained [`here`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak#manually-using-keycloak-ui)

## Deploy book-service

In a terminal and inside `kubernetes-environment/bookservice-kong-keycloak` folder, run the following command to
deploy `book-service`
```
kubectl apply -f yaml-files/bookservice-deployment.yaml
```

## Configuring Kong

### Add service book-service

```
curl -i -X POST http://$KONG_ADMIN_URL/services/ \
  -d 'name=book-service' \
  -d 'protocol=http' \
  -d 'host=bookservice-service' \
  -d 'port=8080'
```

### Add book-service route

```
curl -i -X POST http://$KONG_ADMIN_URL/services/book-service/routes/ \
  -d "protocols[]=http" \
  -d "hosts[]=book-service" \
  -d "strip_path=false"
```

### Test route

In order to test the route, we will use `GET /actuator/health`
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

### Add Rate Limiting plugin

Add plugin to `book-service` service
```
curl -X POST http://$KONG_ADMIN_URL/services/book-service/plugins \
  -d "name=rate-limiting"  \
  -d "config.minute=10"
```

Make some calls to
```
curl -i http://$KONG_PROXY_URL/actuator/health -H 'Host: book-service'
```

After exceeding 10 calls in a minute, you should see
```
HTTP/1.1 429 Too Many Requests
{"message":"API rate limit exceeded"}
```

## Final test

### Call `GET /api/books` endpoint
```
curl -i http://$KONG_PROXY_URL/api/books -H 'Host: book-service'
```

It should return

```
HTTP/1.1 200
[]
```

### Call `POST /api/books` endpoint without access token

```
curl -i -X POST http://$KONG_PROXY_URL/api/books -H 'Host: book-service' \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
HTTP/1.1 302
```

### Get access token from Keycloak

In a terminal, export to an environment variable the `Secret` generated by `Keycloak` to `book-service`. See
[Configure Keycloak](https://github.com/ivangfr/kubernetes-environment/tree/master/bookservice-kong-keycloak#configure-keycloak)
```
export BOOKSERVICE_CLIENT_SECRET=...
```

In `kubernetes-environment/bookservice-kong-keycloak` folder, run the script below to get the access token
```
BEARER_MY_ACCESS_TOKEN=$(./get-access-token.sh $BOOKSERVICE_CLIENT_SECRET)
```

To see the access token value run
```
echo $BEARER_MY_ACCESS_TOKEN
```

### Call `POST /api/books` endpoint informing the access token

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

The script below will delete all deployments
```
./cleanup.sh
```

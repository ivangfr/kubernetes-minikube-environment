# `bookservice-kong-keycloak`

The goal of this project is to run inside [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube)):
[`book-service`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak) (string-boot application),
[`Keycloak`](https://www.keycloak.org) (authentication and authorization service) and
[`Kong`](https://konghq.com) (gateway service).

## Prerequisites

Clone `springboot-testing-mongodb-keycloak` project
```
git clone https://github.com/ivangfr/springboot-testing-mongodb-keycloak.git
```

### book-service

`book-service` is a REST API spring-boot application for managing books. Once deployed in `Kubernetes` cluster, it
won't be exposed to outside, i.e, it won't be possible to be called from host machine. In order to bypass it, we are
going to use `Kong` as a gateway service. So, to access `book-service`, you will have to call `Kong` REST API and then,
it will redirect the request to `book-service`. Furthermore, the plugin `Rate Limiting` will be installed in `Kong`.
It will be configured to just allow 5 calls a minute to `book-service` endpoints.

Besides, `book-service` implements `Keycloak` security configuration. The endpoints related to "managing books", like
`POST /api/books`, `PATCH /api/books/{id}` and `DELETE /api/books/{id}` will require a `Bearer JWT access token` to be
called.

## Start Minikube
```
minikube start
```

## Use Minikube Docker Daemon

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon.
For it, run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```
> When Minikube host won't be used anymore, you can undo this change by running   
> ```
> eval $(minikube docker-env -u)
> ```

## Build Docker Image

- Run the following command inside `springboot-testing-mongodb-keycloak` root folder
```
./gradlew clean build docker -x test -x integrationTest
``` 

- You can check that the `docker.mycompany.com/book-service` docker image was created and is present among other `k8s`
docker images by typing
```
docker images
```

## Deployments

Inside `kubernetes-environment/bookservice-kong-keycloak` root folder, run the following script
```
./deploy-all.sh
```

It will install to `Kubernetes`: `MySQL`, `Postgres`, `MongoDB` `Kong` and Keycloak. It can take some time
(pulling docker images, starting services, etc). You can check the status progress by running
```
kubectl get pods --watch
```

## Services addresses

Run the following script
```
./services-addresses.sh
```

It will get the exposed addresses of `Kong` and `Keycloak`. 

**Copy the output and run it in a terminal. It will export `Kong` and `Keycloak` addresses to environment variables.
Those environment variables will be used on the next steps.**

## Configure Keycloak

Before start, check if Keycloak is ready by running `kubectl get pods`. The column `READY` must show `1/1`. If it is
showing 0/1, wait a little bit.

### Automatically running script
 
- Inside `springboot-testing-mongodb-keycloak` root folder, run the following script
```
./init-keycloak.sh $KEYCLOAK_URL
```

- In the end, the script prints the `BOOKSERVICE_CLIENT_SECRET`. It will be used on the next steps.

### Manually using Keycloak UI

- Open Keyloak UI
```
minikube service keycloak-http
```

- Add realm, client, client-roles and user as explained in https://github.com/ivangfr/springboot-testing-mongodb-keycloak#manually-using-keycloak-ui

## Deploy book-service

In `kubernetes-environment/bookservice-kong-keycloak` root folder, run the following command to deploy `book-service`
```
kubectl apply -f yaml-files/bookservice-deployment.yaml
```

## Configuring Kong

### Add service book-service

```
curl -i -X POST $KONG_ADMIN_URL/services/ \
  -d 'name=book-service' \
  -d 'protocol=http' \
  -d 'host=bookservice-service' \
  -d 'port=8080'
```

### Add book-service route

```
curl -i -X POST $KONG_ADMIN_URL/services/book-service/routes/ \
  -d "protocols[]=http" \
  -d "hosts[]=book-service" \
  -d "strip_path=false"
```

### Test route

In order to test the route, we will use `GET /actuator/health`
```
curl -i $KONG_PROXY_URL/actuator/health -H 'Host: book-service'
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

- Add plugin to `book-service` service
```
curl -X POST $KONG_ADMIN_URL/services/book-service/plugins \
  -d "name=rate-limiting"  \
  -d "config.minute=10"
```

- Make some calls to
```
curl -i $KONG_PROXY_URL/actuator/health -H 'Host: book-service'
```

- After exceeding 10 calls in a minute, you should see
```
HTTP/1.1 429 Too Many Requests
{"message":"API rate limit exceeded"}
```

## Final test

### Try to call `GET /api/books` endpoint
```
curl -i $KONG_PROXY_URL/api/books -H 'Host: book-service'
```

It should return

```
HTTP/1.1 200
[]
```

### Try to call `POST /api/books` endpoint without access token

```
curl -i -X POST $KONG_PROXY_URL/api/books -H 'Host: book-service' \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
HTTP/1.1 302
```

### Get access token from Keycloak

- Run the script below to get the access token
```
BEARER_MY_ACCESS_TOKEN=$(./get-access-token.sh $BOOKSERVICE_CLIENT_SECRET)
```

- To see the access token returned run
```
echo $BEARER_MY_ACCESS_TOKEN
```

### Call `POST /api/books` endpoint informing the access token

```
curl -i -X POST $KONG_PROXY_URL/api/books -H 'Host: book-service' \
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

## Shutdown

- The script below will delete all deployments
```
./cleaning-up.sh
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

## Issue

- **Unable to start Kong using helm chart in Minikube** (https://github.com/helm/charts/issues/13126)
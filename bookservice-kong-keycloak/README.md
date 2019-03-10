# `bookservice-kong-keycloak`

The goal of this project is to run inside [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube)):
[`book-service`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak) (string-boot application),
[`Keycloak`](https://www.keycloak.org) (authentication and authorization service) and
[`Kong`](https://konghq.com) (gateway service).

`book-service` is a REST API spring-boot application for managing books. Once deployed in `Kubernetes` cluster, it
won't be exposed to outside, i.e, it won't be possible to be called from host machine. In order to bypass it, we are
going to use `Kong` as a gateway service. So, to access `book-service`, you will have to call `Kong` REST API and then,
it will redirect the request to `book-service`. Furthermore, the plugin `Rate Limiting` will be installed in `Kong`.
It will be configured to just allow 5 calls a minute to `book-service` endpoints.

Besides, `book-service` implements `Keycloak` security configuration. The endpoints related to "managing books", like
`POST /api/books`, `PATCH /api/books/{id}` and `DELETE /api/books/{id}` will require a `Bearer JWT access token` to be
called.

# Start environment

### Start Minikube
```
minikube start
```

> The command `minikube stop` can be used to stop your cluster. This command shuts down the Minikube Virtual Machine,
but preserves all cluster state and data. Starting the cluster again will restore it to it’s previous state.

> The command `minikube delete` can be used to delete your cluster. This command shuts down and deletes the Minikube
Virtual Machine. No data or state is preserved.

### Start Minikube as explained in the main README

```
minikube start
```

### Clone `springboot-testing-mongodb-keycloak`

```
git clone https://github.com/ivangfr/springboot-testing-mongodb-keycloak.git
```

### Use Minikube Docker Daemon

Because this project uses `Minikube`, instead of pushing your Docker image to a registry, you can simply build the
image using the same Docker host as the `Minikube` VM, so that the images are automatically present. To do so, make
sure you are using the `Minikube` Docker daemon
```
eval $(minikube docker-env)
```

> When Minikube host won't be used anymore, you can undo this change by running   
> ```
> eval $(minikube docker-env -u)
> ```

### Build _springboot-testing-mongodb-keycloak_

Run the following command inside `springboot-testing-mongodb-keycloak` root folder
```
./gradlew clean build docker -x test -x integrationTest
```

You can check that the `docker.mycompany.com/book-service` docker image was created and is present among other `k8s`
docker images by typing
```
docker images
```

### Run _deploy-all.sh_ script

Inside `kubernetes-environment/bookservice-kong-keycloak` root folder, run
```
./deploy-all.sh
```

It will deploy to `Kubernetes`: `MySQL-Keycloak`, `Postgres-Kong` and `MongoDB`. It will take some time (pulling docker
images, starting services, etc). So be patient. You can check the progress by running
```
kubectl get pods
```

> If one of the above deployment did not work, you can delete it using the command below and trying again
> ```
> kubectl delete -f kubernetes/<filename>.yaml
> kubectl create -f kubernetes/<filename>.yaml
> ```

### Run _services-addresses.sh_ script

```
./services-addresses.sh
```

It will get the exposed `Kong` and `Keycloak` addresses. 

**Copy the output and run it on a terminal. It will export `Kong` and `Keycloak` addresses to environment variables.
Those environment variables will be used on the next steps.**

# Configure Keycloak

### Open Keycloak UI

```
minikube service keycloak-service
```

### Add realm, client, client-roles and user

Please, visit https://github.com/ivangfr/springboot-testing-mongodb-keycloak#manually-using-keycloak-ui

# Deploy book-service

### Run the following command to deploy _book-service_

```
kubectl create -f deployment-files/bookservice-deployment.yaml
```

# Configuring Kong

### Add service _book-service_

```
curl -i -X POST http://$KONG_ADDR_8001/services/ \
  -d 'name=book-service' \
  -d 'protocol=http' \
  -d 'host=bookservice-service' \
  -d 'port=8080'
```

### Add _book-service_ route

```
curl -i -X POST http://$KONG_ADDR_8001/services/book-service/routes/ \
  -d "protocols[]=http" \
  -d "hosts[]=book-service" \
  -d "strip_path=false"
```

### Test route

**`GET /actuator/health`**

```
curl -i http://$KONG_ADDR_8000/actuator/health -H 'Host: book-service'
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

### Add _Rate Limiting_ plugin

- Add plugin to `book-service` service

```
curl -X POST http://$KONG_ADDR_8001/services/book-service/plugins \
  -d "name=rate-limiting"  \
  -d "config.minute=5"
```

- Make some calls to

```
curl -i http://$KONG_ADDR_8000/actuator/health -H 'Host: book-service'
```

- After exceeding 5 calls in a minute, you should see

```
HTTP/1.1 429 Too Many Requests
{"message":"API rate limit exceeded"}
```

# Final test

### Try to call `GET /api/books` endpoint
```
curl -i http://$KONG_ADDR_8000/api/books -H 'Host: book-service'
```

It should return

```
HTTP/1.1 200
[]
```

### Try to call `POST /api/books` endpoint without access token

```
curl -i -X POST http://$KONG_ADDR_8000/api/books -H 'Host: book-service' \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
HTTP/1.1 302
```

### Get access token from Keycloak

- Find `book-service` Pod

```
kubectl get pods -l app=bookservice
```

- `kubectl exec` into `book-service` running Pod

```
kubectl exec -it bookservice-deployment-... sh
```

- Inside the container, export to `BOOKSERVICE_CLIENT_SECRET` environment variable the Client Secret generated by
`Keycloak` for `book-service` (Configuring Keycloak > Create a new Client).
```
export BOOKSERVICE_CLIENT_SECRET=...
```

- Still inside the container, run the follow `curl` command to get the access token

```
curl -s -X POST \
  http://keycloak-service:8080/auth/realms/company-services/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=ivan.franchin" \
  -d "password=123" \
  -d "grant_type=password" \
  -d "client_secret=$BOOKSERVICE_CLIENT_SECRET" \
  -d "client_id=book-service" | jq -r .access_token
```

- Copy the access token generated and `exit` the container.

### Export the access token to `MY_ACCESS_TOKEN`

In the host machine, export to `MY_ACCESS_TOKEN` environment variable the access token generated previously
```
export MY_ACCESS_TOKEN=...
```

### Call `POST /api/books` endpoint informing the access token

```
curl -i -X POST http://$KONG_ADDR_8000/api/books -H 'Host: book-service' \
  -H "Authorization: Bearer $MY_ACCESS_TOKEN" \
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

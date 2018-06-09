# bookservice-kong-keycloak

## Goal

The goal of this project is to run inside [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://github.com/kubernetes/minikube)): `book-service` application, [`Keycloak`](https://www.keycloak.org) as an authentication and authorization service and [`Kong`](https://konghq.com) as a gateway tool.

`book-service` is a REST API application for managing books. Once deployed in `Kubernetes` cluster, it won't be exposed to outside, i.e, it won't be possible to be called from host machine. In order to bypass it, we are going to use `Kong` as a gateway. So, to access `book-service`, you will have to call `Kong` REST API and then, it will redirect the request to `book-service`. Furthermore, the plugin `Rate Limiting` will be installed in `Kong`. It will be configured to just allow 5 calls a minute to `book-service` endpoints.

Besides, `book-service` implements `Keycloak` security configuration. The endpoints related to "managing books", like `POST /api/books`, `PATCH /api/books/{id}` and `DELETE /api/books/{id}` will require a `Bearer` JWT access token to be accessed.

## Start environment

#### 1. Clone `springboot-testing-mongodb-keycloak`

```
git clone https://github.com/ivangfr/springboot-testing-mongodb-keycloak.git
```

#### 2. Start Minikube

```
minikube start
```

#### 3. Use Minikube Docker Daemon

Because this project uses `Minikube`, instead of pushing your Docker image to a registry, you can simply build the image using the same Docker host as the `Minikube` VM, so that the images are automatically present. To do so, make sure you are using the `Minikube` Docker daemon
```
eval $(minikube docker-env)
```

> When Minikube host won't be used anymore, you can undo this change by running   
> ```
> eval $(minikube docker-env -u)
> ```

#### 4. Build `springboot-testing-kong`

Inside `sptingboot-testing-kong` root folder type:
```
gradle clean build docker
```

#### 5. Run `deploy-all.sh` script

```
./deploy-all.sh
```

It will deploy to `Kubernetes`: `MySQL-Keycloak`, `Postgres-Kong` and `MongoDB`. It will take some time so be patient. You can check running `minukube dashboard`.

> If one of the above deployment didn't work, you can delete it using the command bellow and try again
> ```
> kubectl delete -f kubernetes/<filename>.yaml
> kubectl create -f kubernetes/<filename>.yaml
> ```

#### 6. Run `services-addresses.sh` script

```
./services-addresses.sh
```

It will get the exposed `Kong` and `Keycloak` addresses. 

**Copy the output and run it on a terminal. It will export `Kong` and `Keycloak` addresses to environment variables. Those environment variables will be used on the next steps.**

## Configure Keycloak

#### 1. Open Keycloak UI

```
http://$KEYCLOAK_ADDR
```
OR
```
minikube service keycloak-service
```

#### 2. Add realm, client, client-roles and user

Please, visit https://github.com/ivangfr/springboot-testing-mongodb-keycloak#manually-using-keycloak-ui

## Deploy book-service

#### Run the following command to deploy book-service

```
kubectl create -f deployment-files/bookservice-deployment.yaml
```

## Configuring Kong

#### 1. Add service book-service

```
curl -i -X POST http://$KONG_ADDR_8001/services/ \
  -d 'name=book-service' \
  -d 'protocol=http' \
  -d 'host=bookservice-service' \
  -d 'port=8080'
```

#### 2. Add book-service route

```
curl -i -X POST http://$KONG_ADDR_8001/services/book-service/routes/ \
  -d "protocols[]=http" \
  -d "hosts[]=book-service" \
  -d "strip_path=false"
```

#### 3. Test if the route is working

**`GET /api/books`**

```
curl -i http://$KONG_ADDR_8000/health -H 'Host: book-service'
```

It should return

```
Code: 200
Response Body: {"status":"UP"}
```

#### 4. Add Rate Limiting plugin

- Add plugin to `book-service` service

```
curl -X POST http://$KONG_ADDR_8001/services/book-service/plugins \
  -d "name=rate-limiting"  \
  -d "config.minute=5"
```

- Make some calls to

```
curl -i http://$KONG_ADDR_8000/health -H 'Host: book-service'
```

- After exceeding 5 calls in a minute, you should see

```
Code: 429 Too Many Requests
Response Body: {"message":"API rate limit exceeded"}
```

## Final test

#### 1. Try to call `GET /api/books` endpoint
```
curl -i http://$KONG_ADDR_8000/api/books -H 'Host: book-service'
```

It should return

```
Code: 200
Response Body: []
```

#### 2. Try to call `POST /api/books` endpoint without access token

```
curl -i -X POST http://$KONG_ADDR_8000/api/books -H 'Host: book-service' \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
Code: 302
```

#### 3. Get access token from Keycloak

- Find `book-service` POD

```
kubectl get pods -l app=bookservice
```

- Get a shell to `book-service` POD running container

```
kubectl exec -it bookservice-deployment-... sh
```

- Inside it, run the follow `cURL` command to get the access token

*Update the `BOOKSERVICE_CLIENT_SECRET` value with the secret generated by Keycloak (Configure Keycloak)*

```
curl -s -X POST \
  "http://keycloak-service:8080/auth/realms/company-services/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=ivan.franchin" \
  -d "password=123" \
  -d "grant_type=password" \
  -d "client_secret=$BOOKSERVICE_CLIENT_SECRET" \
  -d "client_id=book-service" | jq -r .access_token
```

#### 4. Export the access token to `MY_ACCESS_TOKEN`

In the host machine, export the access token generated previously to `MY_ACCESS_TOKEN` environment variable

```
export MY_ACCESS_TOKEN=<access-token-generated-inside-book-service-pod>
```

#### 5. Call `POST /api/books` endpoint informing the access token

```
curl -i -X POST http://$KONG_ADDR_8000/api/books -H 'Host: book-service' \
  -H "Authorization: Bearer $MY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
Code: 201
Response Body: {
  "id":"6d1270d5-716f-46b1-9a9d-e152f62464aa",
  "title":"java 8",
  "authorName":"ivan",
  "price":10.5
}
```

# bookservice-kong-keycloak

## Goal

The goal of this project is to run inside `Kubernetes` (`Minikube`): `book-service` application, `Keycloak` as an authentication and authorization service and `Kong` as a gateway tool.

`book-service` is a REST API application for managing books. Once deployed in `Kubernetes` cluster, it won't be exposed to outside, i.e, it won't be possible to be called from host machine. In order to bypass it, we are going to use `Kong` as a gateway. So, to access `book-service`, you will have to call `Kong` REST API and then, it will redirect the request to `book-service`. Furthermore, the plugin `Rate Limiting` will be installed in `Kong`. It will be configured to just allow 5 calls a minute to `book-service` endpoints.

Besides, `book-service` implements `Keycloak` security configuration. The endpoints related to "managing books", like `POST /api/books`, `PATCH /api/books/{id}` and `DELETE /api/books/{id}` will require a `Bearer` JWT access token to be accessed.

## Starting environment

1. **Clone `springboot-testing-mongodb`**

```
git clone https://github.com/ivangfr/springboot-testing-mongodb-keycloak.git
```

2. **Start `minikube`**

```
minikube start
```

3. **Because this project uses Minikube, instead of pushing your Docker image to a registry, you can simply build the image using the same Docker host as the Minikube VM, so that the images are automatically present. To do so, make sure you are using the Minikube Docker daemon:**

```
eval $(minikube docker-env)
```

**Note**: when Minikube host won't be used anymore, you can undo this change by running

```
eval $(minikube docker-env -u)
```

4. **Build `springboot-testing-kong`**

Inside `sptingboot-testing-kong` root folder type:
```
gradle clean build docker
```

5. **Run the script `deploy-all.sh` to deploy to `Kubernetes`: `MySQL-Keycloak`, `Postgres-Kong` and `MongoDB`**

```
./deploy-all.sh
```

It will take some time so be patient. You can check running `minukube dashboard`. It will open a tab in a browser.

If one of the above deployment didn't work, you can delete it using the command bellow and try again

```
kubectl delete -f kubernetes/<filename>.yaml
kubectl create -f kubernetes/<filename>.yaml
```

6. **Run the script `services-addresses.sh` to get the exposed `Kong` and `Keycloak` addresses**

```
./services-addresses.sh
```

7. **Copy the output and paste on the terminal. It will export `Kong` and `Keycloak` addresses to environment variables**

## Configuring Keycloak

1. **Access the link**
```
http://$KEYCLOAK_ADDR
```

2. **Login with the credentials**
```
Username: admin
Password: admin
```

3. **Create a new Realm**
- Go to top-left corner and hover the mouse over `Master` realm. A blue button `Add realm` will appear. Click on it.
- On `Name` field, write `company-services`. Click on `Create`.

4. **Create a new Client**
- Click on `Clients` menu on the left.
- Click `Create` button.
- On `Client ID` field type `book-service`.
- Click on `Save`.
- On `Settings` tab, set the `Access Type` to `confidential`
- Still on `Settings` tab, set the `Valid Redirect URIs` to `http://localhost:8080/*`
- Click on `Save`.
- Go to `Credentials` tab. Copy the value on `Secret` field. It will be used on the next steps.

5. **Create a new Role**
- Click on `Roles` menu on the left.
- Click `Add Role` button.
- On `Role Name` type `manage_books`.
- Click on `Save`.

6. **Create a new User**
- Click on `Users` menu on the left.
- Click on `Add User` button.
- On `Username` field set `ivan.franchin`
- Click on `Save`
- Go to `Credentials` tab
- Set to `New Password` and `Password Confirmation` the value `123`
- Turn off the `Temporary` field
- Click on `Reset password`
- Confirm the pop up clicking on `Change Password`
- Go to `Role Mappings` tab and add the role `manage_books` to `ivan.franchin`.

**Done!** That is all the configuration needed on Keycloak.

## Deploy `book-service`

1. **Run the following command to deploy `book-service`**

```
kubectl create -f deployment-files/bookservice-deployment.yaml
```

## Configuring Kong

1. **Add service `book-service`**

```
curl -i -X POST http://$KONG_ADDR_8001/services/ \
  -d 'name=book-service' \
  -d 'protocol=http' \
  -d 'host=bookservice-service' \
  -d 'port=8080'
```

2. **Add `book-service` route**

```
curl -i -X POST http://$KONG_ADDR_8001/services/book-service/routes/ \
  -d "protocols[]=http" \
  -d "hosts[]=book-service" \
  -d "strip_path=false"
```

3. **Test if the route is working**

- `GET /api/books`

```
curl -i http://$KONG_ADDR_8000/health -H 'Host: book-service'
```

It should return

```
Code: 200
Response Body: {"status":"UP"}
```

4. **Add `Rate Limiting` plugin**

- Add plugin to `springboot-kong` service

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

1. **Try to call `GET /api/books` endpoint**
```
curl -i http://$KONG_ADDR_8000/api/books -H 'Host: book-service'
```

It should return

```
Code: 200
Response Body: []
```

2. **Try to call `POST /api/books` endpoint without access token**

```
curl -i -X POST http://$KONG_ADDR_8000/api/books -H 'Host: book-service' \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
Code: 302
```

3. **Get access token from `Keycloak`**

- Find `book-service` POD

```
kubectl get pods -l app=bookservice
```

- Get a shell to `book-service` POD running container

```
kubectl exec -it bookservice-deployment-... sh
```

- Inside it, run the follow commands to get the access token

*Update the `BOOKSERVICE_CLIENT_SECRET` value with the secret generated by Keycloak (Configuring Keycloak, step 4)*

```
BOOKSERVICE_CLIENT_SECRET=232dc622-ee81-4025-a911-7f122d7b86e7

curl -s -X POST \
  "http://keycloak-service:8080/auth/realms/company-services/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=ivan.franchin" \
  -d "password=123" \
  -d "grant_type=password" \
  -d "client_secret=$BOOKSERVICE_CLIENT_SECRET" \
  -d "client_id=book-service" | jq -r .access_token

exit
```

4. **In the host machine, save the access token generated previously in the `MY_ACCESS_TOKEN` variable**

```
export MY_ACCESS_TOKEN=<access-token-generated-inside-book-service-pod>
```

5. **Call `POST /api/books` endpoint informing the access token**

```
curl -i -X POST http://$KONG_ADDR_8000/api/books -H 'Host: book-service' \
  -H "Authorization: Bearer $MY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
Code: 201
Response Body: {"id":"6d1270d5-716f-46b1-9a9d-e152f62464aa","title":"java 8","authorName":"ivan","price":10.5}
```

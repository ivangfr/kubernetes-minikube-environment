# keycloak-clustered-mode

## Goal

The goal of this project is to deploy [`keycloak-clustered`](https://github.com/ivangfr/keycloak-clustered) instances in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)).

## Start environment

#### Start Minikube
```
minikube start
```

#### (Optional) Use _Minikube_ Docker Daemon

Because this project uses `Minikube`, instead of pushing your Docker image to a registry, you can simply build the image using the same Docker host as the `Minikube` VM, so that the images are automatically present. To do so, make sure you are using the `Minikube` Docker daemon.
```
eval $(minikube docker-env)
```
> When Minikube host won't be used anymore, you can undo this change by running
> ```
> eval $(minikube docker-env -u)
>```

## Deploy [MySQL](https://www.mysql.com)

There are two options.

#### Using _YAML_ file with [MySQL Docker Image](https://hub.docker.com/_/mysql/)
```
kubectl create -f deployment-files/keycloak-mysql-deployment.yaml
```

#### Using [MySQL Helm Chart](https://github.com/kubernetes/charts/tree/master/stable/mysql)

- Init `Helm`
```
helm init --service-account default
```

- Install `MySQL`
```
helm install --name keycloak \
--set imageTag=5.7.22 \
--set mysqlDatabase=keycloak \
--set mysqlRootPassword=root_password \
--set mysqlUser=keycloak \
--set mysqlPassword=password \
stable/mysql
```

## Deploy _keycloak-clustered_

Run the follwoing command. It will start `Keycloak` in Standalone Clustered Mode with 2 replicas.
```
kubectl create -f deployment-files/keycloak-deployment.yaml
```

## Open Keycloak UI

Run the follwing command to open Keycloak UI in your default browser
```
minikube service keycloak
```
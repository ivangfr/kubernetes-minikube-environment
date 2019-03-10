# `keycloak-clustered-mode`

The goal of this project is to deploy [`keycloak-clustered`](https://github.com/ivangfr/keycloak-clustered) instances
in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)).

# Start environment

### Start Minikube
```
minikube start
```

> The command `minikube stop` can be used to stop your cluster. This command shuts down the Minikube Virtual Machine,
but preserves all cluster state and data. Starting the cluster again will restore it to it’s previous state.

> The command `minikube delete` can be used to delete your cluster. This command shuts down and deletes the Minikube
Virtual Machine. No data or state is preserved.

### (Optional) Use Minikube Docker Daemon

Because this project uses `Minikube`, instead of pushing your Docker image to a registry, you can simply build the
image using the same Docker host as the `Minikube` VM, so that the images are automatically present. To do so, make
sure you are using the `Minikube` Docker daemon.
```
eval $(minikube docker-env)
```
> When Minikube host won't be used anymore, you can undo this change by running
> ```
> eval $(minikube docker-env -u)
>```

# Deploy [MySQL](https://www.mysql.com)

There are two options.

### Using _YAML_ file with [MySQL Docker Image](https://hub.docker.com/_/mysql/)
```
kubectl create -f deployment-files/keycloak-mysql-deployment.yaml
```

### Using [MySQL Helm Chart](https://github.com/kubernetes/charts/tree/master/stable/mysql)

- Init `Helm`
```
helm init --service-account default
```

- Install `MySQL`
```
helm install --name keycloak \
--set imageTag=5.7.25 \
--set mysqlDatabase=keycloak \
--set mysqlRootPassword=root_password \
--set mysqlUser=keycloak \
--set mysqlPassword=password \
stable/mysql
```

# Deploy keycloak-clustered

Run the following command. It will start 2 replicas of `keycloak-clustered` in Standalone Clustered Mode.
```
kubectl create -f deployment-files/keycloak-deployment.yaml
```

# Open Keycloak UI

Run the following command to open Keycloak UI in your default browser
```
minikube service keycloak
```
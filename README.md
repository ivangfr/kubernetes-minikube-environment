# `kubernetes-environment`

The goal of this project is have some examples using [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube))

## Prerequisites

### Tools

You must have `Kubectl`, `Minikube` and `Helm` installed in your machine. Here are the links to websites that explain
how to install [`Kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/),
[`Minikube`](https://kubernetes.io/docs/tasks/tools/install-minikube/) and [`Helm`](https://helm.sh/docs/intro/install/)

### Helm Chart Repositories

Besides, you must have the following `repo`'s added in your helm chart repository list.
```
NAME            URL                                                      
stable          https://kubernetes-charts.storage.googleapis.com/        
incubator       http://storage.googleapis.com/kubernetes-charts-incubator
codecentric     https://codecentric.github.io/helm-charts
```

In order to check it, run
```
helm repo list
```

If some of them is missing, here are the commands to add
```
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo add codecentric https://codecentric.github.io/helm-charts
```

## Examples

- ### [author-book-review-helm-chart](https://github.com/ivangfr/kubernetes-environment/tree/master/author-book-review-helm-chart)

- ### [bookservice-kong-keycloak](https://github.com/ivangfr/kubernetes-environment/tree/master/bookservice-kong-keycloak)

- ### [user-event-sourcing-monitoring](https://github.com/ivangfr/kubernetes-environment/tree/master/user-event-sourcing-monitoring)

## Start Minikube

Open a terminal and start `Minikube` by running the following command. The properties `--memory` and `--vm-driver` are
optional. 
```
minikube start --memory='8000mb' --vm-driver='virtualbox'
```

\[Optional\] Update information of available `Helm` charts locally from chart repositories
```
helm repo update
```

## Shutdown Minikube

The following command shuts down the `Minikube Virtual Machine`, but preserves all cluster state and data. Starting the
cluster again will restore it to it’s previous state.
```
minikube stop
```

The command shuts down and deletes the `Minikube Virtual Machine`. No data or state is preserved.
```
minikube delete
```

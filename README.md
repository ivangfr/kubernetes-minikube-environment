# `kubernetes-environment`

The goal of this project is have some examples using [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube))

## Prerequisites

You must have [`Kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/),
[`Minikube`](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube) and 
[`Helm`](https://helm.sh/docs/using_helm/#installing-the-helm-client) installed.

## Examples

### [bookservice-kong-keycloak](https://github.com/ivangfr/kubernetes-environment/tree/master/bookservice-kong-keycloak)

### [author-book-review-helm-chart](https://github.com/ivangfr/kubernetes-environment/tree/master/author-book-review-helm-chart)

## Start Minikube

Open a terminal and start `Minikube` by running the following command. The properties inside `[]` are optional. 
```
minikube start [--memory='8000mb' --vm-driver='virtualbox']
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

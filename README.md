# `kubernetes-environment`

The goal of this project is have some examples using [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube))

## Prerequisites

You must have [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/),
[Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube) and 
[Helm](https://helm.sh/docs/using_helm/#installing-the-helm-client) installed.

## Examples

### [bookservice-kong-keycloak](https://github.com/ivangfr/kubernetes-environment/tree/master/bookservice-kong-keycloak)

The goal of this project is to run inside `Kubernetes` (`Minikube`): `book-service` application,
[`Keycloak`](https://www.keycloak.org) as an authentication and authorization service and [`Kong`](https://konghq.com)
as a gateway tool.

### [author-book-review-helm-chart](https://github.com/ivangfr/kubernetes-environment/tree/master/author-book-review-helm-chart)

The goal of this project is create Helm Charts for the spring-boot applications
[`author-book-api` and `book-review-api`](https://github.com/ivangfr/springboot-graphql-databases). Then, we will use
the charts to install those applications in `Kubernetes` (`Minikube`).

### More soon
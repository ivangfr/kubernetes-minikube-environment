# kubernetes-minikube-environment

The goal of this project is to have some examples using [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://github.com/kubernetes/minikube)) 

## Prerequisites

- **Tools**

  You must have the following tools installed

  | Tool              | Version I used in the last commit      | Command to check          |
  |-------------------|----------------------------------------|---------------------------|
  | [`Java 17+`][1]   | `17.0.6`                               | `java --version`          |
  | [`Docker`][2]     | Client: `20.10.22`; Server: `20.10.22` | `docker version`          |
  | [`VirtualBox`][3] | `6.1.42r155177`                        | `VBoxManage -version`     |
  | [`Helm`][4]       | `v3.11.1`                              | `helm version`            |
  | [`Minikube`][5]   | `v1.29.0`                              | `minikube version`        |
  | [`Kubectl`][6]    | Client: `v1.22.5`; Server: `v1.23.3`   | `kubectl version --short` |

  [1]:https://www.oracle.com/java/technologies/downloads/#java17
  [2]:https://www.docker.com/
  [3]:https://www.virtualbox.org/
  [4]:https://helm.sh/docs/intro/install/
  [5]:https://kubernetes.io/docs/tasks/tools/install-minikube/
  [6]:https://kubernetes.io/docs/tasks/tools/install-kubectl/

- **Helm Chart Repositories**

  You must have the following `repo`'s added in your helm chart repository list.
  ```
  NAME        	URL
  codecentric 	https://codecentric.github.io/helm-charts/
  kong        	https://charts.konghq.com
  bitnami     	https://charts.bitnami.com/bitnami
  elastic     	https://helm.elastic.co
  confluentinc	https://confluentinc.github.io/cp-helm-charts/
  ```

  In order to check it, run
  ```
  helm repo list
  ```

  If some of them is missing, here are the commands to add
  ```
  helm repo add codecentric https://codecentric.github.io/helm-charts/
  helm repo add kong https://charts.konghq.com
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo add elastic https://helm.elastic.co
  helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
  ```
  
  Run the command below to get the latest information about charts from the chart repositories
  ```
  helm repo update
  ```

## Examples

- ### [author-book-review-graphql](https://github.com/ivangfr/kubernetes-minikube-environment/tree/master/author-book-review-graphql#kubernetes-minikube-environment)
- ### [book-service-kong-keycloak](https://github.com/ivangfr/kubernetes-minikube-environment/tree/master/book-service-kong-keycloak#kubernetes-minikube-environment)
- ### [html-parser-job-cronjob](https://github.com/ivangfr/kubernetes-minikube-environment/tree/master/html-parser-job-cronjob#kubernetes-minikube-environment)
- ### [movies-api-elk-prometheus-grafana](https://github.com/ivangfr/kubernetes-minikube-environment/tree/master/movies-api-elk-prometheus-grafana#kubernetes-minikube-environment)
- ### [user-event-sourcing-kafka](https://github.com/ivangfr/kubernetes-minikube-environment/tree/master/user-event-sourcing-kafka#kubernetes-minikube-environment)

## Start Minikube

- Open a terminal and start `Minikube` by running the following command. The properties `--memory` and `--vm-driver` are optional
  ```
  minikube start --memory='8000mb' --vm-driver='virtualbox'
  ```

- Run the command below to get the latest information about charts from the chart repositories
  ```
  helm repo update
  ```

## Shutdown Minikube

The following command shuts down the `Minikube Virtual Machine`, but preserves all cluster state and data. Starting the cluster again will restore it to its previous state.
```
minikube stop
```

The command shuts down and deletes the `Minikube Virtual Machine`. No data or state is preserved.
```
minikube delete
```

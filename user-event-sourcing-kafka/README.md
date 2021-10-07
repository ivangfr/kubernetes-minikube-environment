# kubernetes-minikube-environment
## `> user-event-sourcing-kafka`

The goal of this example is to create `Helm Charts` for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications [`user-service` and `event-service`](https://github.com/ivangfr/spring-cloud-stream-event-sourcing-testcontainers#applications). Then, these charts will be used to install `user-service` and `event-service` in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)).

As `user-service` uses `MySQL` as storage and `event-service` uses `Cassandra`, these databases will also be installed using their `Helm Charts`. Besides, other services used in this example like `Kafka`, `Zipkin`, etc, will be installed by using their respective `Helm Charts`.

## Clone example repository

- Open a terminal

- Run the following command to clone [`spring-cloud-stream-event-sourcing-testcontainers`](https://github.com/ivangfr/spring-cloud-stream-event-sourcing-testcontainers)
  ```
  git clone https://github.com/ivangfr/spring-cloud-stream-event-sourcing-testcontainers.git
  ```

## Start Minikube

First, start `Minikube` as explained in [Start Minikube](https://github.com/ivangfr/kubernetes-minikube-environment#start-minikube)

## Build Docker Images

- In a terminal, navigate to `spring-cloud-stream-event-sourcing-testcontainers` root folder

- Set `Minikube` host
  ```
  eval $(minikube docker-env)
  ```

- Build `user-service` and `event-service` Docker images so that we don't need to push them to Docker Registry. To do it, run the following script
  ```
  ./docker-build.sh
  ```

- Get back to Host machine Docker Daemon   
  ```
  eval $(minikube docker-env -u)
  ```

## Create a namespace

- In a terminal, run the following command to create a new namespace called `dev`
  ```
  kubectl create namespace dev
  ```
  > To delete run
  > ```
  > kubectl delete namespace dev
  > ```

- \[Optional\] To list all namespaces run
  ```
  kubectl get namespaces
  ```

## Install services

- In a terminal, navigate to `kubernetes-minikube-environment/user-event-sourcing-kafka` folder

- To install the services, run the script below
  ```
  ./install-services.sh
  ```
  > To uninstall run
  > ```
  > ./uninstall-services.sh
  > ```

  It will install `MySQL`, `Cassandra`, `Zookeeper`, `Kafka`, etc. This process will take time because it involves pulling service's docker images and starting them.

- Watch the status/progress of the service's installation
  ```
  kubectl get pods --namespace dev --watch
  ```
  > To stop watching, press `Ctrl+C`

## Install applications

- In a terminal, make sure you are in `kubernetes-minikube-environment/user-event-sourcing-kafka` folder

- Install `user-service`
  ```
  helm install user-service --namespace dev my-charts/user-service
  ```
  > To delete run
  > ```
  > helm delete --namespace dev user-service
  > ```

- Install `event-service`
  ```
  helm install event-service --namespace dev my-charts/event-service
  ```
  > To delete run
  > ```
  > helm delete --namespace dev event-service
  > ```

## Applications & Services URLs

- In a terminal, make sure you are inside `kubernetes-minikube-environment/user-event-sourcing-kafka` folder

- Run the command below to get applications and services URLs
  ```
  ./get-applications-services-urls.sh
  ```
  
## Testing

- Get `user-service` address
  ```
  USER_SERVICE_ADDR="$(minikube ip):$(kubectl get svc -n dev user-service -o go-template='{{(index .spec.ports 0).nodePort}}')"
  ```

- Get `event-service` address
  ```
  EVENT_SERVICE_ADDR="$(minikube ip):$(kubectl get svc -n dev event-service -o go-template='{{(index .spec.ports 0).nodePort}}')"
  ```

- Create a user
  ```
  curl -i -X POST "http://$USER_SERVICE_ADDR/api/users" -H  "Content-Type: application/json" -d '{"email":"ivan.franchin@test.com","fullName":"Ivan Franchin","active":true}'
  ```

- Check whether the event related to the user creation was received by `event-service`
  ```
  curl -i "http://$EVENT_SERVICE_ADDR/api/events?userId=1"
  ```

## Services Configuration

- **Kafka Manager**

  - First, you must create a new cluster. Click on `Cluster` (dropdown button on the header) and then on `Add Cluster`
  - Type the name of your cluster in `Cluster Name` field, for example: `MyCluster`
  - Type `my-kafka-zookeeper:2181` in `Cluster Zookeeper Hosts` field
  - Enable checkbox `Poll consumer information (Not recommended for large # of consumers)`
  - Click on `Save` button at the bottom of the page.

## Cleanup

- In a terminal, make sure you are in `kubernetes-minikube-environment/user-event-sourcing-kafka` folder

- Run the script below to uninstall all services, `user-service` and `event-service` applications and `dev` namespace.
  ```
  ./cleanup.sh
  ```

## TODO

- Add Schema Registry so that we can run `user-service` and `event-service` using `avro` spring profile

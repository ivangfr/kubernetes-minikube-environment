# kubernetes-environment
## `> user-event-sourcing-monitoring`

The goal of this project is to create `Helm Charts` for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications [`user-service` and `event-service`](https://github.com/ivangfr/springboot-kafka-mysql-cassandra). Then, we will use the charts to install those applications in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)). As `user-service` uses `MySQL` as storage and `event-service` uses `Cassandra`, those databases will also be installed using their `Helm Charts` available at https://github.com/helm/charts.

## Clone example repository

Clone [`springboot-kafka-mysql-cassandra`](https://github.com/ivangfr/springboot-kafka-mysql-cassandra) repository. For it, open a terminal and run
```
git clone https://github.com/ivangfr/springboot-kafka-mysql-cassandra.git
```

## Start Minikube

First of all, start `Minikube` as explained in [Start Minikube](https://github.com/ivangfr/kubernetes-environment#start-minikube)

## Build Docker Images

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon. Below are the steps

- In a terminal, navigate to `springboot-kafka-mysql-cassandra` root folder

- Set `Minikube` host
  ```
  eval $(minikube docker-env)
  ```

- Build application's docker images
  ```
  ./build-apps.sh
  ```
   
- \[Optional\] Check whether `user-service` and `event-service` docker images were created
  ```
  docker images
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

- In a terminal, navigate to `kubernetes-environment/user-event-sourcing-monitoring` folder

- To install the services, run the script below
  ```
  ./install-services.sh
  ```
  > To uninstall run
  > ```
  > ./uninstall-services.sh
  > ```

  It will install `MySQL`, `Cassandra`, `Kafka`, `Prometheus-Operator`, etc. This process can take some time (pulling docker images, starting services, etc).

- Check the status/progress of the service installation
  ```
  kubectl get pods --namespace dev
  ```

## Install applications

- In a terminal, make sure you are in `kubernetes-environment/user-event-sourcing-monitoring` folder

- Install `user-service`
  ```
  helm install user-service --namespace dev ./my-charts/user-service
  ```
  > To delete run
  > ```
  > helm delete --namespace dev user-service
  > ```

- Install `event-service`
  ```
  helm install event-service --namespace dev ./my-charts/event-service
  ```
  > To delete run
  > ```
  > helm delete --namespace dev event-service
  > ```

## Applications URLs

In a terminal and, inside `kubernetes-environment/user-event-sourcing-monitoring` folder, run the command below to get services and applications URLs
```
./get-applications-urls.sh
```

You should see something like
```
        Application |                                         URL |         Credentials |
------------------- + ------------------------------------------- + ------------------- |
       user-service | http://192.168.99.126:31488/swagger-ui.html |                     |
      event-service | http://192.168.99.126:30673/swagger-ui.html |                     |
            grafana |                 http://192.168.99.126:30662 | admin/prom-operator |
         prometheus |                 http://192.168.99.126:30090 |                     |
      kafka-manager |                 http://192.168.99.126:31171 |                     |
          my-zipkin |                 http://192.168.99.126:32741 |                     |
 schema-registry-ui |                                             |                     |
```

For more information about how test the `user-service` and `event-service` application, please refer to https://github.com/ivangfr/springboot-kafka-mysql-cassandra#playing-around

## Services Configuration

- **Kafka Manager**

  - First, you must create a new cluster. Click on `Cluster` (dropdown button on the header) and then on `Add Cluster`
  - Type the name of your cluster in `Cluster Name` field, for example: `MyZooCluster`
  - Type `my-kafka-zookeeper:2181` in `Cluster Zookeeper Hosts` field
  - Enable checkbox `Poll consumer information (Not recommended for large # of consumers if ZK is used for offsets tracking on older Kafka versions)`
  - Click on `Save` button at the bottom of the page.

- **Prometheus**

  While installing the `Helms Chart`s of the applications at [Install applications](#install-applications), it was configured, for each application, a `Service Monitor` that calls the `prometheus` endpoint of the application in order to collect some metrics.

  We can check whether the `Service Monitor`s are configured correctly by going to `Prometheus` website. Once there, click on `Status` dropdown menu and then on `Targets`. The reference to `user-service` and `event-service` should be displayed and the status must be `UP`.
  
- **Grafana**

  TODO

## Cleanup

- In a terminal, make sure you are in `kubernetes-environment/user-event-sourcing-monitoring` folder

- Run the script below to uninstall all services, `book-service` application and `dev` namespace.
  ```
  ./cleanup.sh
  ```

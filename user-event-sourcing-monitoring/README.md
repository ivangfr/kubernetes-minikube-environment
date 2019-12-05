# `user-event-sourcing-monitoring`

The goal of this project is to create `Helm Charts` for the [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications [`user-service` and `event-service`](https://github.com/ivangfr/springboot-kafka-mysql-cassandra). Then, we will use the charts to install those applications in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)). As `user-service` uses `MySQL` as storage and `event-service` uses `Cassandra`, those databases will also be installed using their `Helm Charts` available at https://github.com/helm/charts.

## Clone example repository

Clone [`springboot-kafka-mysql-cassandra`](https://github.com/ivangfr/springboot-kafka-mysql-cassandra) repository. For it, open a terminal and run
```
git clone https://github.com/ivangfr/springboot-kafka-mysql-cassandra.git
```

## Start Minikube

First of all, start `Minikube` as explained at [Start Minikube](https://github.com/ivangfr/kubernetes-environment#start-minikube)

## Build Docker Images

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon.

For it, open a terminal and run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```

Then, inside `springboot-kafka-mysql-cassandra` root folder, run the following script
```
./build-apps.sh
```

Once it is finished, run the command below to check that `user-service` and `user-service` docker images were created and are present among other `k8s` images
```
docker images
```

As `Minikube` host won't be used anymore, you can undo this change by running   
```
eval $(minikube docker-env -u)
```

## Create a namespace

Let's create a new namespace called `dev`. For it, in a terminal and inside `kubernetes-environment/user-event-sourcing-monitoring`folder, run the following command
```
kubectl apply -f yaml-files/dev-namespace.yaml
```
> To delete run
> ```
> kubectl delete -f yaml-files/dev-namespace.yaml
> ```

To list all namespaces run
```
kubectl get namespaces
```

## Install services

In a terminal and, inside `kubernetes-environment/user-event-sourcing-monitoring` folder, run the following script
```
./install-services.sh
```
> To uninstall run
> ```
> ./uninstall-services.sh
> ```

It will install a couple of services like `MySQL`, `Cassandra`, `Kafka`, `Prometheus-Operator`, etc. This process can take some time (pulling docker images, starting services, etc). You can check the progress status of the services by running
```
kubectl get pods --namespace dev
```

## Install applications

In a terminal and inside `kubernetes-environment/user-event-sourcing-monitoring`, run the following commands to install the `Helm Chart` of `user-service` and `event-service`.

In order to install `user-service` run
```
helm install user-service --namespace dev ./my-charts/user-service
```
> To delete run
> ```
> helm delete --namespace dev user-service
> ```

To install `event-service` run
```
helm install event-service --namespace dev ./my-charts/event-service
```
> To delete run
> ```
> kubectl delete --namespace dev -f yaml-files/user-service-servicemonitor.yaml
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

For more information about how test the `user-service` and `event-service` application, please refer to https://github.com/ivangfr/springboot-kafka-mysql-cassandra#playing-around-with-the-applications

## Monitoring

While installing the `Helms Chart`s of the applications at [Install applications](#install-applications), it was configured, for each application, a `Service Monitor` that calls the `prometheus` endpoint of the application in order to collect some metrics.

We can check whether the `Service Monitor`s are configured correctly by going to `Prometheus` website. Once there, click on `Status` dropdown menu and then on `Targets`. The reference to `user-service` and `event-service` should be displayed and the status must be `UP`.

We can build some charts in `Grafana` using `Prometheus` metrics. This way, we can monitor our applications.

However, how to create a chart in `Grafana` is out of the scope of this README.

## Cleanup

In a terminal and, inside `kubernetes-environment/user-event-sourcing-monitoring` folder, run the script below to uninstall all services, applications and the `dev` namespace
```
./cleanup.sh
```

# kubernetes-minikube-environment
## `> html-parser-job-cronjob`

The goal of this example is to run, inside [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://github.com/kubernetes/minikube)), two [`Spring Boot`](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/) applications, [`game-score-api` and `game-score-collector`](https://github.com/ivangfr/springboot-jsoup-html-parser). As both applications uses `MongoDB`, we will install the NoSQL DB using its `Helm Chart`.

## Clone example repository

- Open a terminal

- Run the following command to clone [`springboot-jsoup-html-parser`](https://github.com/ivangfr/springboot-jsoup-html-parser)
  ```
  git clone https://github.com/ivangfr/springboot-jsoup-html-parser.git
  ```

## Start Minikube

First of all, start `Minikube` as explained in [Start Minikube](https://github.com/ivangfr/kubernetes-minikube-environment#start-minikube)

## Build Docker Images

- In a terminal, navigate to `springboot-jsoup-html-parser` root folder

- Set `Minikube` host
  ```
  eval $(minikube docker-env)
  ```

- Build `game-score-api` and `game-score-collector` Docker images so that we don't need to push them to Docker Registry.
  - JVM
    ```
    ./build-apps.sh
    ```
  - Native
    ```
    ./build-apps.sh native
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

# Install MongoDB

- In a terminal, to install run
  ```
  helm install my-mongodb \
  --namespace dev \
  --set image.tag=4.4.2-debian-10-r27 \
  --set auth.rootPassword=secret \
  --set auth.database=gamescoredb \
  --set auth.username=gamescoreuser \
  --set auth.password=gamescorepass \
  --set persistence.enabled=false \
  bitnami/mongodb
  ```
  > To uninstall run
  > ```
  > helm delete --namespace dev my-mongodb
  > ```
  
- Watch the status/progress of the installation
  ```
  kubectl get pods --namespace dev --watch
  ```

## Install applications

- In a terminal, make sure you are in `kubernetes-minikube-environment/html-parser-job-cronjob` folder

- Run the job `game-score-collector-job`. It will get data from website for the first time
  ```
  kubectl apply --namespace dev -f deployment-files/game-score-collector-job.yaml
  ```

- Deploy `game-score-api`
  ```
  kubectl apply --namespace dev -f deployment-files/game-score-api-deployment.yaml
  ```

- Deploy the cronjob `game-score-collector-cronjob` that will run every `hh:00, hh:10, hh:20, hh:30, hh:40 and hh:50` to get updated data from website.
  ```
  kubectl apply --namespace dev -f deployment-files/game-score-collector-cronjob.yaml
  ```

- To check the progress of the deployments run
  ```
  kubectl get --namespace dev pods,cronjobs,jobs
  ```

## Testing

- In a terminal, get `GAME_SCORE_API_URL` environment variable
  ```
  GAME_SCORE_API_URL="$(minikube ip):$(kubectl get services --namespace dev game-score-api-service -o go-template='{{(index .spec.ports 0).nodePort}}')"

- Call `game-score-api` endpoint that retrieves all games
  ```
  curl -i http://$GAME_SCORE_API_URL//api/games
  ```

## Cleanup

- In a terminal, make sure you are in `kubernetes-minikube-environment/html-parser-job-cronjob` folder

- Run the script below to uninstall all services, `game-score-api` deployment,  `game-score-collector` job and cronjob and `dev` namespace.
  ```
  ./cleanup.sh
  ```
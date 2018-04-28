kubectl delete -f deployment-files/mysql-keycloak-deployment.yaml
kubectl delete -f deployment-files/postgres-kong-deployment.yaml
kubectl delete -f deployment-files/mongodb-bookservice-deployment.yaml

kubectl delete -f deployment-files/kong-migration-job.yaml

kubectl delete -f deployment-files/kong-deployment.yaml
kubectl delete -f deployment-files/keycloak-deployment.yaml

kubectl delete -f deployment-files/bookservice-deployment.yaml

eval $(minikube docker-env -u)
kubectl delete -f deployment-files/keycloak-mysql-deployment.yaml
kubectl delete -f deployment-files/keycloak-standalone-ha-deployment.yaml
kubectl delete -f deployment-files/keycloak-domain-master-deployment.yaml
kubectl delete -f deployment-files/keycloak-domain-slave-deployment.yaml
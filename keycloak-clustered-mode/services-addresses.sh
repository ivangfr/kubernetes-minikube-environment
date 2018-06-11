MINIKUBE_IP=$(minikube ip)

KEYCLOAK_DOMAIN_MASTER_PORT=$(kubectl get services/keycloak-domain-master-service -o go-template='{{(index .spec.ports 0).nodePort}}')
KEYCLOAK_DOMAIN_SLAVE_PORT=$(kubectl get services/keycloak-domain-slave-service -o go-template='{{(index .spec.ports 0).nodePort}}')

KEYCLOAK_DOMAIN_MASTER_ADDR="$MINIKUBE_IP:$KEYCLOAK_DOMAIN_MASTER_PORT"
KEYCLOAK_DOMAIN_SLAVE_ADDR="$MINIKUBE_IP:$KEYCLOAK_DOMAIN_SLAVE_PORT"

echo "export KEYCLOAK_DOMAIN_MASTER_ADDR=$KEYCLOAK_DOMAIN_MASTER_ADDR"
echo "export KEYCLOAK_DOMAIN_SLAVE_ADDR=$KEYCLOAK_DOMAIN_SLAVE_ADDR"
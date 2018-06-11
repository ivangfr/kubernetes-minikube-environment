# keycloak-clustered-mode

## Goal

The goal of this project is to deploy [`keycloak-clustered`](https://github.com/ivangfr/keycloak-clustered) instances in [`Kubernetes`](https://kubernetes.io) ([`Minikube`](https://kubernetes.io/docs/getting-started-guides/minikube)).

## Start environment

#### Start Minikube
```
minikube start
```

## Deploy [MySQL](https://www.mysql.com)

There are two options.

#### Using _YAML_ file with [MySQL Docker Image](https://hub.docker.com/_/mysql/)
```
kubectl create -f kubernetes/deployment-files/keycloak-mysql-deployment.yaml
```

#### Using [MySQL Helm Chart](https://github.com/kubernetes/charts/tree/master/stable/mysql)

- Init `Helm`
```
helm init --service-account default
```

- Install `MySQL`
```
helm install --name keycloak \
--set imageTag=5.7.22 \
--set mysqlDatabase=keycloak \
--set mysqlRootPassword=root_password \
--set mysqlUser=keycloak \
--set mysqlPassword=password \
stable/mysql
```

## Deploy _keycloak-clustered_

### [Standalone Clustered Mode](https://www.keycloak.org/docs/latest/server_installation/index.html#_standalone-ha-mode)

Run the follwoing command. It will start `Keycloak` in Standalone Clustered Mode with 2 replicas.
```
kubectl create -f kubernetes/deployment-files/keycloak-standalone-ha-deployment.yaml
```

### [Domain Clustered Mode](https://www.keycloak.org/docs/latest/server_installation/index.html#_domain-mode)

**Note: I was not able to run a single Master and Slave configuration (connected to MySQL) in Minikube. Maybe, my machine hasn't enough hardware**
> MacBook Pro, 2.7 GHz Intel Core i5, 16 GB 1867 MHz DDR3

#### Deploy _Keycloak-Domain-Master_

```
kubectl create -f kubernetes/deployment-files/keycloak-domain-master-deployment.yaml
```

#### Add _slave_ user

For more information check [Redhat Documentation](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.0/html-single/how_to_configure_server_security/#securing_managed_domain)
```
./kubernetes/add-slave-user.sh
```
>Type `username = slave` and `password = abc-def1`

```
What type of user do you wish to add? 
 a) Management User (mgmt-users.properties) 
 b) Application User (application-users.properties)
(a): a

Enter the details of the new user to add.
Using realm 'ManagementRealm' as discovered from the existing property files.
Username : slave

Password recommendations are listed below. To modify these restrictions edit the add-user.properties configuration file.
 - The password should be different from the username
 - The password should not be one of the following restricted values {root, admin, administrator}
 - The password should contain at least 8 characters, 1 alphabetic character(s), 1 digit(s), 1 non-alphanumeric symbol(s)
Password : abc-def1
Re-enter Password : abc-def1

What groups do you want this user to belong to? (Please enter a comma separated list, or leave blank for none)[  ]: 

About to add user 'slave' for realm 'ManagementRealm'
Is this correct yes/no? yes

Added user 'slave' to file '/opt/jboss/keycloak/standalone/configuration/mgmt-users.properties'
Added user 'slave' to file '/opt/jboss/keycloak/domain/configuration/mgmt-users.properties'
Added user 'slave' with groups  to file '/opt/jboss/keycloak/standalone/configuration/mgmt-groups.properties'
Added user 'slave' with groups  to file '/opt/jboss/keycloak/domain/configuration/mgmt-groups.properties'
Is this new user going to be used for one AS process to connect to another AS process? 
e.g. for a slave host controller connecting to the master or for a Remoting connection for server to server EJB calls.
yes/no? yes

To represent the user add the following to the server-identities definition <secret value="YWJjLWRlZjE=" />
```

#### Deploy _Keycloak-Domain-Slave_

```
kubectl create -f kubernetes/deployment-files/keycloak-domain-slave-deployment.yaml
```
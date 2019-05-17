# `bookservice-kong-keycloak`

The goal of this project is to run inside [`Kubernetes`](https://kubernetes.io)
([`Minikube`](https://github.com/kubernetes/minikube)):
[`book-service`](https://github.com/ivangfr/springboot-testing-mongodb-keycloak) (string-boot application),
[`Keycloak`](https://www.keycloak.org) (authentication and authorization service) and
[`Kong`](https://konghq.com) (gateway service).

## Prerequisites

Clone `springboot-testing-mongodb-keycloak` project
```
git clone https://github.com/ivangfr/springboot-testing-mongodb-keycloak.git
```

### book-service

`book-service` is a REST API spring-boot web java application for managing books. Once deployed in `Kubernetes` cluster,
it won't be exposed to outside, i.e, it won't be possible to be accessed directly from the host machine. In order to
bypass it, we are going to use `Kong` as a gateway service. So, to access `book-service`, you will have to call `Kong`
REST API and then, `Kong` will redirect the request to `book-service`. Furthermore, the plugin `Rate Limiting` will be
installed in `Kong`. It will be configured to just allow 5 requests a minute to any `book-service` endpoints.

Besides, `book-service` implements `Keycloak` security configuration. The endpoints related to _"managing books"_, like
create book (`POST /api/books`), update book (`PATCH /api/books/{id}`) and delete book (`DELETE /api/books/{id}`) will
require a `Bearer JWT access token`.

## Start Minikube
```
minikube start
```

## Use Minikube Docker Daemon

Instead of pushing the docker image to Docker Registry, we will simply build the image using the `Minikube` Docker daemon.
For it, run the command below to set `Minikube` host.
```
eval $(minikube docker-env)
```
> When Minikube host won't be used anymore, you can undo this change by running   
> ```
> eval $(minikube docker-env -u)
> ```

## Build Docker Image

- Inside `springboot-testing-mongodb-keycloak` root folder, run the following command
```
./gradlew clean build docker -x test -x integrationTest
``` 

- You can check that the `docker.mycompany.com/book-service` docker image was created and is present among other `k8s`
docker images by typing
```
docker images
```

## Deployments

- Init `Helm`
```
helm init --service-account default
```
> Note. Wait a few seconds so that `tiller` get ready. The following error will be throw if `tiller` is not ready yet.
> ```
> Error: could not find a ready tiller pod
> ```

Inside `kubernetes-environment/bookservice-kong-keycloak` root folder, run the following script
```
./deploy-all.sh
```

It will install to `Kubernetes`: `MySQL`, `Postgres`, `MongoDB` `Kong` and Keycloak. It can take some time
(pulling docker images, starting services, etc). You can check the status progress by running
```
kubectl get pods --watch
```

> Note. I have experienced some exceptions on Keycloak startup. It seems some problem while trying to update MySQL table
> ```
> Error: Duplicate column name 'SERVICE_ACCOUNTS_ENABLED' [Failed SQL: ALTER TABLE keycloak.CLIENT ADD SERVICE_ACCOUNTS_ENABLED BIT(1) DEFAULT 0 NOT NULL]
> ```
> The complete log and a naive solution for this problem can be found at
> [Troubleshooting](https://github.com/ivangfr/kubernetes-environment/tree/master/bookservice-kong-keycloak#troubleshooting) section 

## Services addresses

Run the following script
```
./services-addresses.sh
```

It will get the exposed addresses of `Kong` and `Keycloak`. 

**Copy the output and run it in a terminal. It will export `Kong` and `Keycloak` addresses to environment variables.
Those environment variables will be used on the next steps.**

## Configure Keycloak

Before start, check if Keycloak is ready by running `kubectl get pods`. The column `READY` must show `1/1`. If it is
showing 0/1, wait a little bit.

### Automatically running script
 
- Inside `springboot-testing-mongodb-keycloak` root folder, run the following script
```
./init-keycloak.sh $KEYCLOAK_URL
```

- In the end, the script prints the `BOOKSERVICE_CLIENT_SECRET`. It will be used on the next steps.

### Manually using Keycloak UI

- Open Keyloak UI
```
minikube service keycloak-http
```

- Add realm, client, client-roles and user as explained in https://github.com/ivangfr/springboot-testing-mongodb-keycloak#manually-using-keycloak-ui

## Deploy book-service

In `kubernetes-environment/bookservice-kong-keycloak` root folder, run the following command to deploy `book-service`
```
kubectl apply -f yaml-files/bookservice-deployment.yaml
```

## Configuring Kong

### Add service book-service

```
curl -i -X POST http://$KONG_ADMIN_URL/services/ \
  -d 'name=book-service' \
  -d 'protocol=http' \
  -d 'host=bookservice-service' \
  -d 'port=8080'
```

### Add book-service route

```
curl -i -X POST http://$KONG_ADMIN_URL/services/book-service/routes/ \
  -d "protocols[]=http" \
  -d "hosts[]=book-service" \
  -d "strip_path=false"
```

### Test route

In order to test the route, we will use `GET /actuator/health`
```
curl -i http://$KONG_PROXY_URL/actuator/health -H 'Host: book-service'
```

It should return

```
HTTP/1.1 200
{
  "status": "UP",
  "details": {
    "diskSpace": {
      "status": "UP",
      "details": {
      	...
      }
    },
    "mongo": {
      "status": "UP",
      "details": {
        ...
      }
    }
  }
}
```

### Add Rate Limiting plugin

- Add plugin to `book-service` service
```
curl -X POST http://$KONG_ADMIN_URL/services/book-service/plugins \
  -d "name=rate-limiting"  \
  -d "config.minute=10"
```

- Make some calls to
```
curl -i http://$KONG_PROXY_URL/actuator/health -H 'Host: book-service'
```

- After exceeding 10 calls in a minute, you should see
```
HTTP/1.1 429 Too Many Requests
{"message":"API rate limit exceeded"}
```

## Final test

### Call `GET /api/books` endpoint
```
curl -i http://$KONG_PROXY_URL/api/books -H 'Host: book-service'
```

It should return

```
HTTP/1.1 200
[]
```

### Call `POST /api/books` endpoint without access token

```
curl -i -X POST http://$KONG_PROXY_URL/api/books -H 'Host: book-service' \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
HTTP/1.1 302
```

### Get access token from Keycloak

- Run the script below to get the access token
```
BEARER_MY_ACCESS_TOKEN=$(./get-access-token.sh $BOOKSERVICE_CLIENT_SECRET)
```

- To see the access token returned run
```
echo $BEARER_MY_ACCESS_TOKEN
```

### Call `POST /api/books` endpoint informing the access token

```
curl -i -X POST http://$KONG_PROXY_URL/api/books -H 'Host: book-service' \
  -H "Authorization: $BEARER_MY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "authorName": "ivan", "title": "java 8", "price": 10.5 }'
```

It should return

```
HTTP/1.1 201 
{
  "id":"6d1270d5-716f-46b1-9a9d-e152f62464aa",
  "title":"java 8",
  "authorName":"ivan",
  "price":10.5
}
```

## Shutdown

- The script below will delete all deployments
```
./cleaning-up.sh
```

- The following command shuts down the Minikube Virtual Machine, but preserves all cluster state and data. Starting the
cluster again will restore it to it’s previous state.
```
minikube stop
```

- The command shuts down and deletes the Minikube Virtual Machine. No data or state is preserved.
```
minikube delete
```

# Troubleshooting

If `Keycloak` is not getting up, run the script below. It will redeploy `MySQL` and `Keycloak`.
```
./redeploy-mysql-keycloak.sh
```

*LOG*
```
ERROR [org.keycloak.connections.jpa.updater.liquibase.conn.DefaultLiquibaseConnectionProvider] (ServerService Thread Pool -- 60) Change Set META-INF/jpa-changelog-1.4.0.xml::1.4.0::bburke@redhat.com failed.  Error: Duplicate column name 'SERVICE_ACCOUNTS_ENABLED' [Failed SQL: ALTER TABLE keycloak.CLIENT ADD SERVICE_ACCOUNTS_ENABLED BIT(1) DEFAULT 0 NOT NULL]
ERROR [org.jboss.msc.service.fail] (ServerService Thread Pool -- 60) MSC000001: Failed to start service jboss.deployment.unit."keycloak-server.war".undertow-deployment: org.jboss.msc.service.StartException in service jboss.deployment.unit."keycloak-server.war".undertow-deployment: java.lang.RuntimeException: RESTEASY003325: Failed to construct public org.keycloak.services.resources.KeycloakApplication(javax.servlet.ServletContext,org.jboss.resteasy.core.Dispatcher)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentService$1.run(UndertowDeploymentService.java:81)
        at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
        at java.util.concurrent.FutureTask.run(FutureTask.java:266)
        at org.jboss.threads.ContextClassLoaderSavingRunnable.run(ContextClassLoaderSavingRunnable.java:35)
        at org.jboss.threads.EnhancedQueueExecutor.safeRun(EnhancedQueueExecutor.java:1985)
        at org.jboss.threads.EnhancedQueueExecutor$ThreadBody.doRunTask(EnhancedQueueExecutor.java:1487)
        at org.jboss.threads.EnhancedQueueExecutor$ThreadBody.run(EnhancedQueueExecutor.java:1378)
        at java.lang.Thread.run(Thread.java:748)
        at org.jboss.threads.JBossThread.run(JBossThread.java:485)
Caused by: java.lang.RuntimeException: RESTEASY003325: Failed to construct public org.keycloak.services.resources.KeycloakApplication(javax.servlet.ServletContext,org.jboss.resteasy.core.Dispatcher)
        at org.jboss.resteasy.core.ConstructorInjectorImpl.construct(ConstructorInjectorImpl.java:164)
        at org.jboss.resteasy.spi.ResteasyProviderFactory.createProviderInstance(ResteasyProviderFactory.java:2769)
        at org.jboss.resteasy.spi.ResteasyDeployment.createApplication(ResteasyDeployment.java:363)
        at org.jboss.resteasy.spi.ResteasyDeployment.startInternal(ResteasyDeployment.java:276)
        at org.jboss.resteasy.spi.ResteasyDeployment.start(ResteasyDeployment.java:88)
        at org.jboss.resteasy.plugins.server.servlet.ServletContainerDispatcher.init(ServletContainerDispatcher.java:119)
        at org.jboss.resteasy.plugins.server.servlet.HttpServletDispatcher.init(HttpServletDispatcher.java:36)
        at io.undertow.servlet.core.LifecyleInterceptorInvocation.proceed(LifecyleInterceptorInvocation.java:117)
        at org.wildfly.extension.undertow.security.RunAsLifecycleInterceptor.init(RunAsLifecycleInterceptor.java:78)
        at io.undertow.servlet.core.LifecyleInterceptorInvocation.proceed(LifecyleInterceptorInvocation.java:103)
        at io.undertow.servlet.core.ManagedServlet$DefaultInstanceStrategy.start(ManagedServlet.java:303)
        at io.undertow.servlet.core.ManagedServlet.createServlet(ManagedServlet.java:143)
        at io.undertow.servlet.core.DeploymentManagerImpl$2.call(DeploymentManagerImpl.java:583)
        at io.undertow.servlet.core.DeploymentManagerImpl$2.call(DeploymentManagerImpl.java:554)
        at io.undertow.servlet.core.ServletRequestContextThreadSetupAction$1.call(ServletRequestContextThreadSetupAction.java:42)
        at io.undertow.servlet.core.ContextClassLoaderSetupAction$1.call(ContextClassLoaderSetupAction.java:43)
        at org.wildfly.extension.undertow.security.SecurityContextThreadSetupAction.lambda$create$0(SecurityContextThreadSetupAction.java:105)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentInfoService$UndertowThreadSetupAction.lambda$create$0(UndertowDeploymentInfoService.java:1502)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentInfoService$UndertowThreadSetupAction.lambda$create$0(UndertowDeploymentInfoService.java:1502)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentInfoService$UndertowThreadSetupAction.lambda$create$0(UndertowDeploymentInfoService.java:1502)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentInfoService$UndertowThreadSetupAction.lambda$create$0(UndertowDeploymentInfoService.java:1502)
        at io.undertow.servlet.core.DeploymentManagerImpl.start(DeploymentManagerImpl.java:596)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentService.startContext(UndertowDeploymentService.java:97)
        at org.wildfly.extension.undertow.deployment.UndertowDeploymentService$1.run(UndertowDeploymentService.java:78)
        ... 8 more
Caused by: java.lang.RuntimeException: Failed to update database
        at org.keycloak.connections.jpa.updater.liquibase.LiquibaseJpaUpdaterProvider.update(LiquibaseJpaUpdaterProvider.java:116)
        at org.keycloak.connections.jpa.updater.liquibase.LiquibaseJpaUpdaterProvider.update(LiquibaseJpaUpdaterProvider.java:81)
        at org.keycloak.connections.jpa.DefaultJpaConnectionProviderFactory.update(DefaultJpaConnectionProviderFactory.java:331)
        at org.keycloak.connections.jpa.DefaultJpaConnectionProviderFactory.migration(DefaultJpaConnectionProviderFactory.java:317)
        at org.keycloak.connections.jpa.DefaultJpaConnectionProviderFactory.lambda$lazyInit$0(DefaultJpaConnectionProviderFactory.java:182)
        at org.keycloak.models.utils.KeycloakModelUtils.suspendJtaTransaction(KeycloakModelUtils.java:678)
        at org.keycloak.connections.jpa.DefaultJpaConnectionProviderFactory.lazyInit(DefaultJpaConnectionProviderFactory.java:133)
        at org.keycloak.connections.jpa.DefaultJpaConnectionProviderFactory.create(DefaultJpaConnectionProviderFactory.java:81)
        at org.keycloak.connections.jpa.DefaultJpaConnectionProviderFactory.create(DefaultJpaConnectionProviderFactory.java:59)
        at org.keycloak.services.DefaultKeycloakSession.getProvider(DefaultKeycloakSession.java:195)
        at org.keycloak.models.jpa.JpaRealmProviderFactory.create(JpaRealmProviderFactory.java:51)
        at org.keycloak.models.jpa.JpaRealmProviderFactory.create(JpaRealmProviderFactory.java:33)
        at org.keycloak.services.DefaultKeycloakSession.getProvider(DefaultKeycloakSession.java:195)
        at org.keycloak.services.DefaultKeycloakSession.realmLocalStorage(DefaultKeycloakSession.java:152)
        at org.keycloak.models.cache.infinispan.RealmCacheSession.getRealmDelegate(RealmCacheSession.java:148)
        at org.keycloak.models.cache.infinispan.RealmCacheSession.getMigrationModel(RealmCacheSession.java:141)
        at org.keycloak.migration.MigrationModelManager.migrate(MigrationModelManager.java:84)
        at org.keycloak.services.resources.KeycloakApplication.migrateModel(KeycloakApplication.java:250)
        at org.keycloak.services.resources.KeycloakApplication.migrateAndBootstrap(KeycloakApplication.java:191)
        at org.keycloak.services.resources.KeycloakApplication$1.run(KeycloakApplication.java:150)
        at org.keycloak.models.utils.KeycloakModelUtils.runJobInTransaction(KeycloakModelUtils.java:227)
        at org.keycloak.services.resources.KeycloakApplication.<init>(KeycloakApplication.java:141)
        at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
        at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
        at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
        at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
        at org.jboss.resteasy.core.ConstructorInjectorImpl.construct(ConstructorInjectorImpl.java:152)
        ... 31 more
Caused by: liquibase.exception.MigrationFailedException: Migration failed for change set META-INF/jpa-changelog-1.4.0.xml::1.4.0::bburke@redhat.com:
     Reason: liquibase.exception.DatabaseException: Duplicate column name 'SERVICE_ACCOUNTS_ENABLED' [Failed SQL: ALTER TABLE keycloak.CLIENT ADD SERVICE_ACCOUNTS_ENABLED BIT(1) DEFAULT 0 NOT NULL]
        at liquibase.changelog.ChangeSet.execute(ChangeSet.java:619)
        at liquibase.changelog.visitor.UpdateVisitor.visit(UpdateVisitor.java:51)
        at liquibase.changelog.ChangeLogIterator.run(ChangeLogIterator.java:79)
        at liquibase.Liquibase.update(Liquibase.java:214)
        at liquibase.Liquibase.update(Liquibase.java:192)
        at liquibase.Liquibase.update(Liquibase.java:188)
        at org.keycloak.connections.jpa.updater.liquibase.LiquibaseJpaUpdaterProvider.updateChangeSet(LiquibaseJpaUpdaterProvider.java:182)
        at org.keycloak.connections.jpa.updater.liquibase.LiquibaseJpaUpdaterProvider.update(LiquibaseJpaUpdaterProvider.java:102)
        ... 57 more
Caused by: liquibase.exception.DatabaseException: Duplicate column name 'SERVICE_ACCOUNTS_ENABLED' [Failed SQL: ALTER TABLE keycloak.CLIENT ADD SERVICE_ACCOUNTS_ENABLED BIT(1) DEFAULT 0 NOT NULL]
        at liquibase.executor.jvm.JdbcExecutor$ExecuteStatementCallback.doInStatement(JdbcExecutor.java:309)
        at liquibase.executor.jvm.JdbcExecutor.execute(JdbcExecutor.java:55)
        at liquibase.executor.jvm.JdbcExecutor.execute(JdbcExecutor.java:113)
        at liquibase.database.AbstractJdbcDatabase.execute(AbstractJdbcDatabase.java:1277)
        at liquibase.database.AbstractJdbcDatabase.executeStatements(AbstractJdbcDatabase.java:1259)
        at liquibase.changelog.ChangeSet.execute(ChangeSet.java:582)
        ... 64 more
Caused by: com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: Duplicate column name 'SERVICE_ACCOUNTS_ENABLED'
        at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
        at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
        at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
        at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
        at com.mysql.jdbc.Util.handleNewInstance(Util.java:425)
        at com.mysql.jdbc.Util.getInstance(Util.java:408)
        at com.mysql.jdbc.SQLError.createSQLException(SQLError.java:944)
        at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3976)
        at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3912)
        at com.mysql.jdbc.MysqlIO.sendCommand(MysqlIO.java:2530)
        at com.mysql.jdbc.MysqlIO.sqlQueryDirect(MysqlIO.java:2683)
        at com.mysql.jdbc.ConnectionImpl.execSQL(ConnectionImpl.java:2482)
        at com.mysql.jdbc.ConnectionImpl.execSQL(ConnectionImpl.java:2440)
        at com.mysql.jdbc.StatementImpl.executeInternal(StatementImpl.java:845)
        at com.mysql.jdbc.StatementImpl.execute(StatementImpl.java:745)
        at org.jboss.jca.adapters.jdbc.WrappedStatement.execute(WrappedStatement.java:198)
        at liquibase.executor.jvm.JdbcExecutor$ExecuteStatementCallback.doInStatement(JdbcExecutor.java:307)
        ... 69 more
```
# Helm chart for geoserver-cloud

![Version: 0.0.14](https://img.shields.io/badge/Version-0.0.14-informational?style=flat-square) ![AppVersion: 1.0-RC5](https://img.shields.io/badge/AppVersion-1.0--RC5-informational?style=flat-square)

A Helm chart for Geoserver

## include this chart as dependency of your own chart:

just include the following section in your `Chart.yaml`:

```yaml
dependencies:
  - name: geoservercloud
    repository: https://camptocamp.github.io/helm-geoserver-cloud
    version: <version-numer-here>
```

See the value file for configuration options.

## Developing on geoserver-cloud code using this chart

To develop in this chart, we recommend that you use `k3d` if you want to use your machine. Please follow the following steps to ensure that you have all the requirements for development:

### install k3d

basically just do:

```bash
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.4.8 bash
```

### install kubectl

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```

or follow the steps of [the official documentation](https://v1-18.docs.kubernetes.io/docs/tasks/tools/install-kubectl/)

### install helm (version 3!!!!)

follow the steps of the [official documentation](https://helm.sh/docs/intro/install/)

### install k3d

```bash
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.4.8 bash
```

### create a cluster on your machine

The following configuration will create a single-node "cluster" on your machine, the kubelet parameters ensure that it works also if you have an almost full development PC. It will also bind the port `localhost:8081` of your machine with the ingress controller port `80`, just adapt accordingly to your needs. You also need a local image registry to push your local images into the cluster.

```bash
# create a local registry
k3d registry create registry.localhost --port 5000

# create a local cluster and enable the registry
k3d cluster create k3d-cluster-1 --registry-use k3d-registry.localhost --k3s-agent-arg '--kubelet-arg=eviction-soft-grace-period=imagefs.available=60s,nodefs.available=60s'  --k3s-agent-arg '--kubelet-arg=eviction-soft=imagefs.available<1%,nodefs.available<1%'  --k3s-agent-arg '--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%' --k3s-agent-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%'  -p "8081:80@loadbalancer" --agents 2
```

### start the chart

```bash
# update the dependencies the first time as well
helm dependency update
# then install the chart
helm install geoserver .
```

### test that it is working.

If everything went well you should see something similar with kubectl:

```bash
~# kubectl get po
NAME                                   READY   STATUS    RESTARTS   AGE
geoserver-postgresql-0                 1/1     Running   0          6m17s
geoserver-discovery-6694fdccb6-92sxn   1/1     Running   0          6m17s
geoserver-config-7b64cf454-hjqrv       1/1     Running   0          6m17s
geoserver-rabbitmq-0                   1/1     Running   0          6m17s
geoserver-gateway-7d99c5c864-wpbt4     1/1     Running   0          6m17s
geoserver-webui-67dfc967d7-x8cx8       1/1     Running   0          6m17s
geoserver-rest-577ddb7854-pjhv2        1/1     Running   0          6m17s
geoserver-wms-7798c78cfd-ngwdm         1/1     Running   0          6m17s
geoserver-wcs-748c9fb64b-flxts         1/1     Running   0          6m17s
geoserver-wfs-65947f5d4d-88g26         1/1     Running   0          6m17s
```

and you should be able to access the webui on http://localhost:8081/web/

### use a local docker image and import it into the cluster

1. build your image, tag and name it:

```bash
docker build -t k3d-registry.localhost:5000/geoserver-cloud-webui:test .
```

And push it to the localhost registry

```bash
docker push k3d-registry.localhost:5000/geoserver-cloud-webui:test
```

and then upgrade (or start) the chart with the following argument:

```bash
helm upgrade --set geoserver.webui.image.repository=k3d-registry.localhost:5000/geoserver-cloud-webui --set geoserver.webui.image.tag=test geoserver .
```

NB: this should not be the case with modern OS, but you might need to add the following to your `/etc/hosts` configuration:

```
127.0.0.1 k3d-registry.localhost
```

## Chart Requirements

| Repository                         | Name     | Version |
| ---------------------------------- | -------- | ------- |
| https://charts.bitnami.com/bitnami | rabbitmq | 8.0.1   |

## Values

| Key                                                        | Type   | Default                              | Description |
| ---------------------------------------------------------- | ------ | ------------------------------------ | ----------- |
| geoserver.config.affinity                                  | object | `{}`                                 |             |
| geoserver.config.env                                       | list   | `[]`                                 |             |
| geoserver.config.image.repository                          | string | `"geoservercloud/config-service"`    |             |
| geoserver.config.image.tag                                 | string | `""`                                 |             |
| geoserver.config.nodeSelector."node.kubernetes.io/role"    | string | `"sig"`                              |             |
| geoserver.config.podAnnotations                            | object | `{}`                                 |             |
| geoserver.config.podSecurityContext.runAsUser              | int    | `630`                                |             |
| geoserver.config.replicaCount                              | int    | `1`                                  |             |
| geoserver.config.resources.limits.memory                   | string | `"600Mi"`                            |             |
| geoserver.config.resources.requests.cpu                    | string | `"100m"`                             |             |
| geoserver.config.resources.requests.memory                 | string | `"300Mi"`                            |             |
| geoserver.config.securityContext                           | object | `{}`                                 |             |
| geoserver.config.service.port                              | int    | `8080`                               |             |
| geoserver.config.service.type                              | string | `"ClusterIP"`                        |             |
| geoserver.config.tolerations[0].effect                     | string | `"NoSchedule"`                       |             |
| geoserver.config.tolerations[0].key                        | string | `"node.kubernetes.io/role"`          |             |
| geoserver.config.tolerations[0].operator                   | string | `"Equal"`                            |             |
| geoserver.config.tolerations[0].value                      | string | `"sig"`                              |             |
| geoserver.database.dropOnDelete                            | bool   | `false`                              |             |
| geoserver.database.extensions[0]                           | string | `"pg_stat_statements"`               |             |
| geoserver.database.secretConfig                            | string | `"jdbcconfig"`                       |             |
| geoserver.discovery.affinity                               | object | `{}`                                 |             |
| geoserver.discovery.env                                    | list   | `[]`                                 |             |
| geoserver.discovery.image.repository                       | string | `"geoservercloud/discovery-service"` |             |
| geoserver.discovery.image.tag                              | string | `""`                                 |             |
| geoserver.discovery.nodeSelector."node.kubernetes.io/role" | string | `"sig"`                              |             |
| geoserver.discovery.podAnnotations                         | object | `{}`                                 |             |
| geoserver.discovery.podSecurityContext.runAsUser           | int    | `630`                                |             |
| geoserver.discovery.replicaCount                           | int    | `1`                                  |             |
| geoserver.discovery.resources.limits.cpu                   | string | `"300m"`                             |             |
| geoserver.discovery.resources.limits.memory                | string | `"600Mi"`                            |             |
| geoserver.discovery.resources.requests.cpu                 | string | `"100m"`                             |             |
| geoserver.discovery.resources.requests.memory              | string | `"300Mi"`                            |             |
| geoserver.discovery.securityContext                        | object | `{}`                                 |             |
| geoserver.discovery.service.port                           | int    | `8761`                               |             |
| geoserver.discovery.service.type                           | string | `"ClusterIP"`                        |             |
| geoserver.discovery.tolerations[0].effect                  | string | `"NoSchedule"`                       |             |
| geoserver.discovery.tolerations[0].key                     | string | `"node.kubernetes.io/role"`          |             |
| geoserver.discovery.tolerations[0].operator                | string | `"Equal"`                            |             |
| geoserver.discovery.tolerations[0].value                   | string | `"sig"`                              |             |
| geoserver.gateway.affinity                                 | object | `{}`                                 |             |
| geoserver.gateway.env                                      | list   | `[]`                                 |             |
| geoserver.gateway.image.repository                         | string | `"geoservercloud/gateway-service"`   |             |
| geoserver.gateway.image.tag                                | string | `""`                                 |             |
| geoserver.gateway.nodeSelector."node.kubernetes.io/role"   | string | `"sig"`                              |             |
| geoserver.gateway.podAnnotations                           | object | `{}`                                 |             |
| geoserver.gateway.podSecurityContext.runAsUser             | int    | `630`                                |             |
| geoserver.gateway.replicaCount                             | int    | `1`                                  |             |
| geoserver.gateway.resources.limits.memory                  | string | `"800Mi"`                            |             |
| geoserver.gateway.resources.requests.cpu                   | string | `"100m"`                             |             |
| geoserver.gateway.resources.requests.memory                | string | `"400Mi"`                            |             |
| geoserver.gateway.securityContext                          | object | `{}`                                 |             |
| geoserver.gateway.service.port                             | int    | `8080`                               |             |
| geoserver.gateway.service.type                             | string | `"ClusterIP"`                        |             |
| geoserver.gateway.tolerations[0].effect                    | string | `"NoSchedule"`                       |             |
| geoserver.gateway.tolerations[0].key                       | string | `"node.kubernetes.io/role"`          |             |
| geoserver.gateway.tolerations[0].operator                  | string | `"Equal"`                            |             |
| geoserver.gateway.tolerations[0].value                     | string | `"sig"`                              |             |
| geoserver.name                                             | string | `"geoserver"`                        |             |
| geoserver.rabbitmq.port                                    | int    | `5672`                               |             |
| geoserver.rest.affinity                                    | object | `{}`                                 |             |
| geoserver.rest.env                                         | list   | `[]`                                 |             |
| geoserver.rest.image.repository                            | string | `"geoservercloud/rest-service"`      |             |
| geoserver.rest.image.tag                                   | string | `""`                                 |             |
| geoserver.rest.nodeSelector."node.kubernetes.io/role"      | string | `"sig"`                              |             |
| geoserver.rest.podAnnotations                              | object | `{}`                                 |             |
| geoserver.rest.podSecurityContext.runAsUser                | int    | `630`                                |             |
| geoserver.rest.replicaCount                                | int    | `1`                                  |             |
| geoserver.rest.resources.limits.memory                     | string | `"1Gi"`                              |             |
| geoserver.rest.resources.requests.cpu                      | string | `"200m"`                             |             |
| geoserver.rest.resources.requests.memory                   | string | `"512Mi"`                            |             |
| geoserver.rest.securityContext                             | object | `{}`                                 |             |
| geoserver.rest.service.port                                | int    | `8080`                               |             |
| geoserver.rest.service.type                                | string | `"ClusterIP"`                        |             |
| geoserver.rest.tolerations[0].effect                       | string | `"NoSchedule"`                       |             |
| geoserver.rest.tolerations[0].key                          | string | `"node.kubernetes.io/role"`          |             |
| geoserver.rest.tolerations[0].operator                     | string | `"Equal"`                            |             |
| geoserver.rest.tolerations[0].value                        | string | `"sig"`                              |             |
| geoserver.serviceAccount.annotations                       | object | `{}`                                 |             |
| geoserver.serviceAccount.create                            | bool   | `true`                               |             |
| geoserver.serviceAccount.name                              | string | `""`                                 |             |
| geoserver.terraform_job.extraEnvs                          | list   | `[]`                                 |             |
| geoserver.terraform_job.extraNamespaces                    | list   | `[]`                                 |             |
| geoserver.terraform_job.image.name                         | string | `"sig/geoserver-tf"`                 |             |
| geoserver.terraform_job.image.pullPolicy                   | string | `"IfNotPresent"`                     |             |
| geoserver.terraform_job.image.registry                     | string | `""`                                 |             |
| geoserver.terraform_job.image.tag                          | string | `"master"`                           |             |
| geoserver.terraform_job.resources.limits.cpu               | string | `"200m"`                             |             |
| geoserver.terraform_job.resources.limits.memory            | string | `"128Mi"`                            |             |
| geoserver.terraform_job.resources.requests.cpu             | string | `"100m"`                             |             |
| geoserver.terraform_job.resources.requests.memory          | string | `"64Mi"`                             |             |
| geoserver.wcs.affinity                                     | object | `{}`                                 |             |
| geoserver.wcs.env                                          | list   | `[]`                                 |             |
| geoserver.wcs.image.repository                             | string | `"geoservercloud/wcs-service"`       |             |
| geoserver.wcs.image.tag                                    | string | `""`                                 |             |
| geoserver.wcs.nodeSelector."node.kubernetes.io/role"       | string | `"sig"`                              |             |
| geoserver.wcs.podAnnotations                               | object | `{}`                                 |             |
| geoserver.wcs.podSecurityContext.runAsUser                 | int    | `630`                                |             |
| geoserver.wcs.replicaCount                                 | int    | `1`                                  |             |
| geoserver.wcs.resources.limits.memory                      | string | `"800Mi"`                            |             |
| geoserver.wcs.resources.requests.cpu                       | string | `"100m"`                             |             |
| geoserver.wcs.resources.requests.memory                    | string | `"400Mi"`                            |             |
| geoserver.wcs.securityContext                              | object | `{}`                                 |             |
| geoserver.wcs.service.port                                 | int    | `8080`                               |             |
| geoserver.wcs.service.type                                 | string | `"ClusterIP"`                        |             |
| geoserver.wcs.tolerations[0].effect                        | string | `"NoSchedule"`                       |             |
| geoserver.wcs.tolerations[0].key                           | string | `"node.kubernetes.io/role"`          |             |
| geoserver.wcs.tolerations[0].operator                      | string | `"Equal"`                            |             |
| geoserver.wcs.tolerations[0].value                         | string | `"sig"`                              |             |
| geoserver.webui.affinity                                   | object | `{}`                                 |             |
| geoserver.webui.env                                        | list   | `[]`                                 |             |
| geoserver.webui.image.repository                           | string | `"geoservercloud/webui-service"`     |             |
| geoserver.webui.image.tag                                  | string | `""`                                 |             |
| geoserver.webui.nodeSelector."node.kubernetes.io/role"     | string | `"sig"`                              |             |
| geoserver.webui.podAnnotations                             | object | `{}`                                 |             |
| geoserver.webui.podSecurityContext.runAsUser               | int    | `630`                                |             |
| geoserver.webui.replicaCount                               | int    | `1`                                  |             |
| geoserver.webui.resources.limits.memory                    | string | `"1Gi"`                              |             |
| geoserver.webui.resources.requests.cpu                     | string | `"300m"`                             |             |
| geoserver.webui.resources.requests.memory                  | string | `"512Mi"`                            |             |
| geoserver.webui.securityContext                            | object | `{}`                                 |             |
| geoserver.webui.service.port                               | int    | `8080`                               |             |
| geoserver.webui.service.type                               | string | `"ClusterIP"`                        |             |
| geoserver.webui.tolerations[0].effect                      | string | `"NoSchedule"`                       |             |
| geoserver.webui.tolerations[0].key                         | string | `"node.kubernetes.io/role"`          |             |
| geoserver.webui.tolerations[0].operator                    | string | `"Equal"`                            |             |
| geoserver.webui.tolerations[0].value                       | string | `"sig"`                              |             |
| geoserver.wfs.affinity                                     | object | `{}`                                 |             |
| geoserver.wfs.env                                          | list   | `[]`                                 |             |
| geoserver.wfs.image.repository                             | string | `"geoservercloud/wfs-service"`       |             |
| geoserver.wfs.image.tag                                    | string | `""`                                 |             |
| geoserver.wfs.nodeSelector."node.kubernetes.io/role"       | string | `"sig"`                              |             |
| geoserver.wfs.podAnnotations                               | object | `{}`                                 |             |
| geoserver.wfs.podSecurityContext.runAsUser                 | int    | `630`                                |             |
| geoserver.wfs.replicaCount                                 | int    | `1`                                  |             |
| geoserver.wfs.resources.limits.memory                      | string | `"800Mi"`                            |             |
| geoserver.wfs.resources.requests.cpu                       | string | `"200m"`                             |             |
| geoserver.wfs.resources.requests.memory                    | string | `"400Mi"`                            |             |
| geoserver.wfs.securityContext                              | object | `{}`                                 |             |
| geoserver.wfs.service.port                                 | int    | `8080`                               |             |
| geoserver.wfs.service.type                                 | string | `"ClusterIP"`                        |             |
| geoserver.wfs.tolerations[0].effect                        | string | `"NoSchedule"`                       |             |
| geoserver.wfs.tolerations[0].key                           | string | `"node.kubernetes.io/role"`          |             |
| geoserver.wfs.tolerations[0].operator                      | string | `"Equal"`                            |             |
| geoserver.wfs.tolerations[0].value                         | string | `"sig"`                              |             |
| geoserver.wms.affinity                                     | object | `{}`                                 |             |
| geoserver.wms.env                                          | list   | `[]`                                 |             |
| geoserver.wms.image.repository                             | string | `"geoservercloud/wms-service"`       |             |
| geoserver.wms.image.tag                                    | string | `""`                                 |             |
| geoserver.wms.nodeSelector."node.kubernetes.io/role"       | string | `"sig"`                              |             |
| geoserver.wms.podAnnotations                               | object | `{}`                                 |             |
| geoserver.wms.podSecurityContext.runAsUser                 | int    | `630`                                |             |
| geoserver.wms.replicaCount                                 | int    | `1`                                  |             |
| geoserver.wms.resources.limits.memory                      | string | `"800Mi"`                            |             |
| geoserver.wms.resources.requests.cpu                       | string | `"100m"`                             |             |
| geoserver.wms.resources.requests.memory                    | string | `"400Mi"`                            |             |
| geoserver.wms.securityContext                              | object | `{}`                                 |             |
| geoserver.wms.service.port                                 | int    | `8080`                               |             |
| geoserver.wms.service.type                                 | string | `"ClusterIP"`                        |             |
| geoserver.wms.tolerations[0].effect                        | string | `"NoSchedule"`                       |             |
| geoserver.wms.tolerations[0].key                           | string | `"node.kubernetes.io/role"`          |             |
| geoserver.wms.tolerations[0].operator                      | string | `"Equal"`                            |             |
| geoserver.wms.tolerations[0].value                         | string | `"sig"`                              |             |
| global.app_environment_name                                | string | `"master"`                           |             |
| global.base_environment_name                               | string | `"dev"`                              |             |
| global.cluster_environment                                 | string | `"dev"`                              |             |
| global.custom_pod_labels                                   | object | `{}`                                 |             |
| global.deployed_by                                         | string | `"argocd"`                           |             |
| global.image.pullPolicy                                    | string | `"Always"`                           |             |
| global.revision                                            | string | `"HEAD"`                             |             |
| rabbitmq.auth.existingErlangSecret                         | string | `"geoserver-rabbitmq"`               |             |
| rabbitmq.auth.existingPasswordSecret                       | string | `"geoserver-rabbitmq"`               |             |
| rabbitmq.auth.username                                     | string | `"geoserver"`                        |             |
| rabbitmq.image.registry                                    | string | `"docker.io"`                        |             |
| rabbitmq.image.repository                                  | string | `"bitnami/rabbitmq"`                 |             |
| rabbitmq.image.tag                                         | string | `"3.8.9-debian-10-r37"`              |             |
| rabbitmq.persistence.enabled                               | bool   | `false`                              |             |

---

Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)

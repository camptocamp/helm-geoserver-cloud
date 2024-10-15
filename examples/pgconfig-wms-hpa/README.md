# HPA example

This example allows to create a very simple GeoserverCloud deployment in your local cluster, which allows to evaluate and understand how Horizontal Pod Autoscaling (HPA) works.

The setup includes:

- a unique WebUI instance, (to allow see catalog configuration)
- the gateway, (access to the GeoserverCloud solution)
- 2 WMS instances, (the initial 2 instances which serve the WMS OGC protocol)
- a REST API instance, (used by attached script that allows to create a minimal catalog for testing)
- a local Postgres and (used along with PgConfig profile, since we want to minimize startup time, so we focus on reducing catalog reading)
- RabbitMQ (the bus event communication across instances)

Following steps mentioned in next section you will be able to see how HPA works automatically (up to 100 containers created!), when the cluster is stressed by the attached script defined for that.

# Considerations

- Read documentation in ../README.md file (since for running this demo, it's required to have a local cluster installed, along with kubectl)
- Execution of this kind of tests could freeze your machine, if your hardware/setup is not adequate.
- If in doubt, change values in the HPA section on the values.yaml file, so you can determine which is the value for maxReplicas (by default = 100)

# Steps

At repository base folder level, follow next steps:

1. Execute

```shell
    make example-wms-hpa
```

2. Use

```shell
   kubectl get po
```

in order to check that all the pods are up and running (that is, all of them with values STATUS = Running and READY = 1/1)
ie.

```shell
NAME                                                     READY   STATUS    RESTARTS   AGE
gs-cloud-pgconfig-wms-hpa-gsc-gateway-76b46b9c7f-gs976   1/1     Running   0          12m
gs-cloud-pgconfig-wms-hpa-postgresql-0                   1/1     Running   0          12m
gs-cloud-pgconfig-wms-hpa-gsc-rest-7fdbcf799f-qshn5      1/1     Running   0          12m
gs-cloud-pgconfig-wms-hpa-gsc-webui-6cf8f88695-646xt     1/1     Running   0          12m
gs-cloud-common-rabbitmq-0                               1/1     Running   0          12m
gs-cloud-pgconfig-wms-hpa-gsc-wms-758dfd8765-qs946       1/1     Running   0          11m
gs-cloud-pgconfig-wms-hpa-gsc-wms-758dfd8765-pth59       1/1     Running   0          10m
```

3. Define a DNS alias (used in scripts to avoid local references. Note: you can edit scripts if you prefer)

```shell
   kubectl get ingress --no-headers  gs-cloud-pgconfig-wm-geoserver-host1 | awk '{printf("%s\t%s\n",$4,$3 )}' | sudo tee -a /etc/hosts
```

3. Execute

```shell
   ./examples/pgconfig-wms-hpa/init-catalog.sh
```

4. Execute

```shell
   watch kubectl get po
```

in order to see list of pods (and watch every 2 secs)

5. In a different console, execute

```shell
   ./examples/pgconfig-wms-hpa/stress-server.sh
```

so you will trigger 1000 simultaneous request to the cluster.

At this point you will be able to see (in console 1) how the list of pods are increased and decreased during execution of the stress-server.sh script.

6. Execute

```shell
   make examples-clean
```

so you get your environment clean, and deployment down.

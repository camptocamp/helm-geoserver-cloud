# Examples

To run these examples, you will install a local k8s on your machine, also a PG database and an NFS mount.

## Setup a local K3D cluster

### install kubectl

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```

or follow the steps of [the official documentation](https://v1-18.docs.kubernetes.io/docs/tasks/tools/install-kubectl/)

### install helm (version 3!!!!)

follow the steps of the [official documentation](https://helm.sh/docs/intro/install/)

### install k3d

```bash
wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

### create a cluster on your machine

The following configuration will create a single-node "cluster" on your machine, the kubelet parameters ensure that it works also if you have a development PC with a disk almost full. It will also bind the port `localhost:8085` of your machine with the ingress controller port `80`, just adapt accordingly to your needs. You also need a local image registry to push your local images into the cluster.

```bash
# create a local registry
k3d registry create registry.localhost --port 5000

# create a local cluster and enable the registry
k3d cluster create k3d-cluster-1 --k3s-arg '--kubelet-arg=eviction-soft-grace-period=imagefs.available=60s,nodefs.available=60s@all'  --k3s-arg '--kubelet-arg=eviction-hard=imagefs.available<10Mi,nodefs.available<10Mi@all' --k3s-arg '--kubelet-arg=eviction-minimum-reclaim=imagefs.available=10Mi,nodefs.available=10Mi@all'  -p "8085:80@loadbalancer"
```


## Setup the example database

Create a temporary postgis local docker container:

```shell
pg_data_dir=$(mktemp -d)
docker run --rm --name=local_db \
  --env=POSTGRES_PASSWORD=password \
  --env=POSTGRES_USER=postgres \
  --env=POSTGRES_DB=postgres \
  --detach --volume ${pg_data_dir}:/var/lib/postgresql/data \
  --publish=5432:5432 postgis/postgis:12-3.4-alpine
```

NB: here we setup a temporary dir to host the PG data, but you can simply change the `pg_data_dir` variable to point to any local persistent folder on your machine to keep the data for the next time.

So now lets setup the database for the examples. Connect to to PG:

```shell
PGPASSWORD=password psql -h localhost -p 5432 -U postgres
```

Then create a database

```sql
CREATE DATABASE ogscloud;
CREATE ROLE username WITH LOGIN PASSWORD 'password';
ALTER DATABASE ogscloud OWNER TO username ;
```

Go in the freshly created DB:

```sql
\c ogscloud
```

And finish the setup:

```sql
CREATE EXTENSION postgis;
CREATE SCHEMA data;
CREATE SCHEMA config;
```

## Setup an NFS server for the examples

To use the datadir example and in general for the GWC tile cache, let's start an NFS server on the host.

```shell
sudo apt install -y nfs-kernel-server nfs-common
sudo mkdir -p /nfs/{raster,datadir,tiles}
sudo chown nobody:nogroup /nfs/{raster,datadir,tiles}
sudo chmod 777 /nfs/{raster,datadir,tiles}
echo '/nfs/datadir *(rw,sync,no_subtree_check)
/nfs/tiles *(rw,sync,no_subtree_check)
/nfs/raster *(rw,sync,no_subtree_check)' | sudo tee -a /etc/exports
sudo exportfs -a
```

## Launch the examples

Using the `Makefile` located at the root of the repository, you can run both examples, but you should run only one at a time.

First please ensure that you executed:

```shell
make dependencies
```

Once done, then you will be able to execute the different examples.

NB:
- In root project folder, you will find that a charts/ folder was created along with the Chart.lock file.
- If you miss this step, then gscloud containers won't be created.

To run the `datadir` example:

```shell
make example-datadir
```

To run the `jdbcconfig` example:

```shell
make example-jdbc
```

To run the `pgconfig` example:

```shell
make example-pgconfig
```

To stop anything and cleanup:

```shell
make examples-clean
```

NB: you should run `make examples-clean` before testing another example, to avoid conflicts.

## Check that it is running and start to play

### test that it is working.

If everything went well you should see something similar with kubectl:

```shell
~# kubectl get po
NAME                                               READY   STATUS    RESTARTS   AGE
gs-cloud-jdbc-geoserver-wms-8c8794f55-zn86w        1/1     Running   0          43m
gs-cloud-jdbc-geoserver-wms-8c8794f55-6ww25        1/1     Running   0          43m
gs-cloud-jdbc-geoserver-gwc-d479ff6c-8mmq8         1/1     Running   0          43m
gs-cloud-jdbc-geoserver-wfs-64b676cb59-27blc       1/1     Running   0          43m
gs-cloud-jdbc-geoserver-wcs-84c75596b7-7ntg6       1/1     Running   0          43m
gs-cloud-jdbc-geoserver-wfs-64b676cb59-qrq46       1/1     Running   0          43m
gs-cloud-jdbc-geoserver-rest-7c5685996c-c8pmk      1/1     Running   0          43m
gs-cloud-jdbc-geoserver-webui-66845fb55f-nc22q     1/1     Running   0          43m
gs-cloud-jdbc-geoserver-gateway-665b698959-tcdlf   1/1     Running   0          43m
gs-cloud-jdbc-geoserver-gwc-d479ff6c-5mktd         1/1     Running   0          43m
gs-cloud-common-rabbitmq-0                         1/1     Running   0          44m

```

### create a DNS alias for the ingress

The examples use `gscloud.local` DNS for the ingress, so you can add that to your `/etc/hosts` to point on the local address of the ingress for more comfort:

```shell
kubectl get ingress --no-headers  gs-cloud-jdbc-geoserver-host1 | awk '{printf("%s\t%s\n",$4,$3 )}' | sudo tee -a /etc/hosts
```

and now you should be able to access the webui on http://gscloud.local/geoserver-cloud/web

## Requirements

| Repository                         | Name       | Version |
| ---------------------------------- | ---------- | ------- |
| oci://ghcr.io/georchestra/bitnami-helm-charts | rabbitmq   | 14.4.0  |
| oci://ghcr.io/georchestra/bitnami-helm-charts | postgresql   | 15.5.2  |

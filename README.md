# Helm chart for GeoServer-Cloud

A Helm chart for GeoServer-Cloud

## include this chart as dependency of your own chart:

This chart is intended to be used as a dependency in a "umbrella chart". To use it, include the following section in your `Chart.yaml`:

```yaml
dependencies:
  - name: geoservercloud
    repository: https://camptocamp.github.io/helm-geoserver-cloud
    version: <version-numer-here>
```

See the value file for configuration options. A good starting points are the [Examples](examples/README.md)

## Developing on geoserver-cloud code using this chart

To develop in this chart, we recommend that you use `k3d` if you want to use your machine.
Also, depending on the use case, you will need a database or a shared folder which will be used by the pods. At any case, start following the [Examples](examples/README.md) !

## Contributing

Install the pre-commit hooks:

```bash
pip install pre-commit
pre-commit install --allow-missing-config
```

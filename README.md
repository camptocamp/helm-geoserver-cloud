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

To develop in this chart, we recommend that you use `k3d` if you want to use your machine. Please follow the following steps to ensure that you have all the requirements for development:

### check that the configuration is available

This repository provides a default configuration thanks to a git submodule : if you don't have performed a recursive clone of the repository, don't forget to do a `git submodule update` before installing the chart !

## Contributing

Install the pre-commit hooks:

```bash
pip install pre-commit
pre-commit install --allow-missing-config
```

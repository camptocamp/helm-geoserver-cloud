# Helm chart for geoserver-cloud

![Version: 0.0.49](https://img.shields.io/badge/Version-0.0.49-informational?style=flat-square) ![AppVersion: 1.0-RC30](https://img.shields.io/badge/AppVersion-1.0--RC30-informational?style=flat-square)

A Helm chart for Geoserver

## include this chart as dependency of your own chart:

just include the following section in your `Chart.yaml`:

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

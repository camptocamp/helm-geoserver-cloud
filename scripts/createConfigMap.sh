#!/bin/bash -e

configDir=$(mktemp -d )
cp submodule_config/*.yml $configDir
sed -i -E 's/([[:space:]]|\r)+$//g' $configDir/*
kubectl create configmap TEMPLATE_STRING --from-file=$configDir --dry-run=client -o yaml > templates/config/configmap.yaml
sed -i 's,TEMPLATE_STRING,{{ include "geoserver.fullname" . }}-config-configs\n  labels:\n    {{- include "geoserver.labels" . | nindent 4 }}\n    app.kubernetes.io/component: "config"',g templates/config/configmap.yaml
rm -r $configDir

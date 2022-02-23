{{/*
Expand the name of the chart.
*/}}
{{- define "geoserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 42 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "geoserver.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 42 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 42 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 42 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geoserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "geoserver.labels" -}}
helm.sh/chart: {{ include "geoserver.chart" . }}
deployed_by: {{ .Values.global.deployed_by }}
app.kubernetes.io/app_environment: "{{ .Values.global.app_environment_name }}"
app.kubernetes.io/base_environment: "{{ .Values.global.base_environment_name }}"
{{ include "geoserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geoserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "geoserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "geoserver.serviceAccountName" -}}
{{- if .Values.geoserver.serviceAccount.create }}
{{- default (include "geoserver.fullname" .) .Values.geoserver.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.geoserver.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate content of spring config for rabbitmq
*/}}
{{- define "geoserver.spring.rabbitmq" -}}
host: {{ .Release.Name }}-rabbitmq
port: 5672
username: {{ .Values.rabbitmq.auth.username }}
password: ${RABBITMQ_PASSWORD}
{{- end }}


{{- define "geoserver.common.env.variables" -}}
{{ $profiles := splitList "," .Values.global.profile }}
- name: GEOSERVER_BASE_PATH
  value: {{ if not (hasSuffix "/" .Values.geoserver.ingress.baseUrl) }} {{ .Values.geoserver.ingress.baseUrl }} {{else}} {{ trimSuffix "/" .Values.geoserver.ingress.baseUrl }} {{ end }}
{{- if eq .Values.geoserver.debug.instanceId true }}
- name: GEOSERVER_DEBUG_INSTANCEID
  value: "true"
{{- end }}
- name: BACKEND_CATALOG
  value: {{ has "catalog" $profiles | quote}}
- name: BACKEND_DATA_DIRECTORY
  value: {{ has "datadir" $profiles | quote}}
- name: BACKEND_JDBCCONFIG
  value: {{ has "jdbcconfig" $profiles | quote}}
{{- if .Values.geoserver.envVariables }}
{{- range $key, $definition := .Values.geoserver.envVariables }}
- name: {{ $definition.name }}
  {{- if $definition.value }}
  value: {{ $definition.value | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ $definition.secretName }}
      key: {{ $definition.secretKey }}
  {{- end }}
{{- end }}
{{- end }}
{{- if not .Values.geoserver.jdbc.external }}
- name: JDBCCONFIG_DATABASE
  valueFrom:
    secretKeyRef:
      name: {{ .Values.geoserver.database.secretConfig }}-{{ include "geoserver.fullname" . }}
      key: DATABASE_NAME
- name: JDBCCONFIG_HOST
  valueFrom:
    secretKeyRef:
      name: {{ .Values.geoserver.database.secretConfig }}-{{ include "geoserver.fullname" . }}
      key: HOST
- name: JDBCCONFIG_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.geoserver.database.secretConfig }}-{{ include "geoserver.fullname" . }}
      key: ROLE
- name: JDBCCONFIG_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.geoserver.database.secretConfig }}-{{ include "geoserver.fullname" . }}
      key: PASSWORD
- name: JDBCCONFIG_PORT
  valueFrom:
    secretKeyRef:
      name: {{ .Values.geoserver.database.secretConfig }}-{{ include "geoserver.fullname" . }}
      key: PORT
{{- else }}
# FIXME: should also be set from some secret etc
{{- range $key, $definition := .Values.geoserver.jdbc.configVariables }}
- name: {{ $definition.name }}
  {{- if $definition.value }}
  value: {{ $definition.value | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ $definition.secretName }}
      key: {{ $definition.secretKey }}
  {{- end }}
{{- end }}
{{- end }}
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: geoserver-rabbitmq
      key: rabbitmq-password
- name: RABBITMQ_PASS
  valueFrom:
    secretKeyRef:
      name: geoserver-rabbitmq
      key: rabbitmq-password
- name: RABBITMQ_HOST
  value: {{ include "geoserver.fullname" . }}-rabbitmq
{{- end }}

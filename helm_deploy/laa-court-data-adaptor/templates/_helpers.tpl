{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "laa-court-data-adaptor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "laa-court-data-adaptor.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "laa-court-data-adaptor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laa-court-data-adaptor.labels" -}}
helm.sh/chart: {{ include "laa-court-data-adaptor.chart" . }}
{{ include "laa-court-data-adaptor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laa-court-data-adaptor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laa-court-data-adaptor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "laa-court-data-adaptor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "laa-court-data-adaptor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Function to return a list of whitelisted IPs allowed to access the service.
These include Pingdom IPs to allow uptime monitoring,
Cloud Platform IPs to allow access to services running in Cloud Platform,
VPN IPs to allow access to developers, and possibly HMCTS IPs too
*/}}
{{- define "laa-court-data-adaptor.whitelist" -}}
{{- if .Values.ips.restrict }}
  {{- .Values.pingdomIps }},{{- .Values.vpnIps }},{{- .Values.ips.hmcts }},{{ include "laa-court-data-adaptor.cloudPlatformIps" . }}
{{- end -}}
{{- end }}

{{/*
Function to return a list of Cloud Platform IPs
*/}}
{{- define "laa-court-data-adaptor.cloudPlatformIps" -}}
35.178.209.113,3.8.51.207,35.177.252.54
{{- end -}}


{{/*
Function to return a list of whitelisted IPs allowed to access the service
via the external ingress
*/}}
{{- define "laa-court-data-adaptor.externalWhitelist" -}}
{{- if .Values.ips.restrict }}
  {{- .Values.ips.hmcts }}
{{- end -}}
{{- end }}

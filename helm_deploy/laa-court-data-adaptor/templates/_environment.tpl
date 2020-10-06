{{/* vim: set filetype=mustache: */}}
{{/*
Environment variables for api and worker containers
*/}}
{{- define "laa-court-data-adaptor.env-vars" }}
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: laa-court-data-adaptor-instance-output
        key: url
  - name: REDIS_URL
    valueFrom:
      secretKeyRef:
        name: ec-cluster-output
        key: url
  - name: RAILS_ENV
    value: 'production'
  - name: HOST_ENV
    value: {{ .Values.rails.host_env }}
  - name: SECRET_KEY_BASE
    value: {{ .Values.rails.secret_key_base }}
  - name: COMMON_PLATFORM_URL
    value: {{ .Values.common_platform_url }}
  - name: SHARED_SECRET_KEY
    value: {{ .Values.common_platform_secret_key }}
  {{- if .Values.mtls_enabled }}
  - name: SSL_CLIENT_CERT
    value: |
      {{ .Files.Get .Values.ssl_cert_file | nindent 6 }}
  - name: SSL_CLIENT_KEY
    value: |
      {{ .Files.Get .Values.ssl_key_file | nindent 6 }}
  {{- end }}
  {{- if .Values.sqs_messaging_enabled }}
  - name: AWS_LINK_QUEUE_URL
    valueFrom:
      secretKeyRef:
        name: cda-messaging-queues-output
        key: sqs_url_link
  - name: AWS_UNLINK_QUEUE_URL
    valueFrom:
      secretKeyRef:
        name: cda-messaging-queues-output
        key: sqs_url_unlink
  - name: AWS_HEARING_RESULTED_QUEUE_URL
    valueFrom:
      secretKeyRef:
        name: cda-messaging-queues-output
        key: sqs_url_hearing_resulted
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: cda-messaging-queues-output
        key: access_key_id
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: cda-messaging-queues-output
        key: secret_access_key
  {{- end }}
  {{- if .Values.maat_api.validation_enabled }}
  - name: MAAT_API_OAUTH_URL
    value: {{ .Values.maat_api.oauth_url }}
  - name: MAAT_API_API_URL
    value: {{ .Values.maat_api.api_url }}
  - name: MAAT_API_CLIENT_ID
    value: {{ .Values.maat_api.client_id }}
  - name: MAAT_API_CLIENT_SECRET
    value: {{ .Values.maat_api.client_secret }}
  {{- end }}
  - name: AWS_REGION
    value: {{ .Values.sqs_region }}
  - name: SENTRY_DSN
    value: {{ .Values.sentry_dsn }}
  - name: SENTRY_CURRENT_ENV
    value: {{ .Values.rails.host_env }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Environment variables for api and worker containers
*/}}
{{- define "laa-court-data-adaptor.env-vars" }}
env:
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: rds-instance-output
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
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: secret_key_base
  - name: COMMON_PLATFORM_URL
    value: {{ .Values.common_platform_url }}
  - name: SHARED_SECRET_KEY
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: common_platform_secret_key
  - name: SSL_CLIENT_CERT
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: hmcts_cert
  - name: SSL_CLIENT_KEY
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: hmcts_key
  - name: SIDEKIQ_UI_USERNAME
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: sidekiq_ui_username
  - name: SIDEKIQ_UI_PASSWORD
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: sidekiq_ui_password
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
  - name: AWS_PROSECUTION_CONCLUDED_QUEUE_URL
    valueFrom:
      secretKeyRef:
        name: cda-messaging-queues-output
        key: sqs_url_prosecution_concluded
  {{- end }}
  {{- if .Values.maat_api.validation_enabled }}
  - name: MAAT_API_OAUTH_URL
    value: {{ .Values.maat_api.oauth_url }}
  - name: MAAT_API_API_URL
    value: {{ .Values.maat_api.api_url }}
  - name: MAAT_API_CLIENT_ID
    valueFrom:
      secretKeyRef:
        name: maat-api-oauth-client-credentials
        key: MAAT_API_CLIENT_ID
  - name: MAAT_API_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: maat-api-oauth-client-credentials
        key: MAAT_API_CLIENT_SECRET
  {{- end }}
  - name: AWS_REGION
    value: {{ .Values.sqs_region }}
  - name: SENTRY_DSN
    valueFrom:
      secretKeyRef:
        name: aws-secrets
        key: sentry_dsn
  - name: SENTRY_CURRENT_ENV
    value: {{ .Values.rails.host_env }}
  - name: METRICS_SERVICE_HOST
    value: {{ include "laa-court-data-adaptor.fullname" . }}
  - name: ACCESS_IP_RESTRICTED
    value: '{{ .Values.ips.restrict }}'
  - name: BREACH_COURT_APPLICATIONS
    value: '{{ .Values.featureFlags.breachCourtApplications }}'
{{- end -}}

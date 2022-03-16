## Monitoring

- [Prometheus](#prometheus)
- [Grafana](#grafana)
- [Alerting](#alerting)

### Prometheus

The [prometheus_exporter gem](https://github.com/discourse/prometheus_exporter) is used to collect application metrics.

Currently the exporter runs in a separate container (laa-court-data-adaptor-metrics-*) on the default port 9394 within the same pod as the application containers (laa-court-data-adaptor-*).

Metrics are scraped by [Cloud Platform's Prometheus instance](https://prometheus.cloud-platform.service.justice.gov.uk/graph), and can be queried by executing a suitable promql query, e.g.

```
ruby_http_duration_seconds_sum{namespace="laa-court-data-ui-staging"}
```

### Alerting

PrometheusRules for AlertManager alert conditions are defined in [prometheus.yaml](https://github.com/ministryofjustice/cloud-platform-environments/blob/main/namespaces/live.cloud-platform.service.justice.gov.uk/laa-court-data-adaptor-prod/08-prometheus-rule.yaml) for each namespace.

Changes to these alerts are applied automatically by Cloud Platform Concourse.

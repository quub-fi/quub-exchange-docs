---
layout: docs
title: Production Deployment
permalink: /guides/production-deployment/
description: Deploy your integration to production with monitoring and observability
---

# Production Deployment

Deploy your Quub Exchange integration to production with confidence.

## Pre-Deployment Checklist

- [ ] All tests passing (unit, integration, E2E)
- [ ] Security audit completed
- [ ] API keys rotated to production
- [ ] Rate limiting configured
- [ ] Monitoring and alerting set up
- [ ] Disaster recovery plan documented
- [ ] Load testing completed

## Deployment Strategies

### Blue-Green Deployment

```bash
# Deploy to green environment
kubectl apply -f k8s/green-deployment.yaml

# Run health checks
./scripts/health-check.sh green

# Switch traffic
kubectl patch service quub-app -p '{"spec":{"selector":{"version":"green"}}}'

# Monitor for 10 minutes
sleep 600

# If successful, remove blue
kubectl delete deployment quub-app-blue
```

### Canary Deployment

```yaml
# k8s/canary-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quub-app-canary
spec:
  replicas: 1 # 10% of traffic
  template:
    metadata:
      labels:
        app: quub-app
        version: canary
```

## Monitoring

### Prometheus Metrics

```javascript
// metrics.js
import { Counter, Histogram } from "prom-client";

export const metrics = {
  apiCalls: new Counter({
    name: "quub_api_calls_total",
    help: "Total API calls",
    labelNames: ["endpoint", "status"],
  }),

  latency: new Histogram({
    name: "quub_api_latency_seconds",
    help: "API call latency",
    buckets: [0.1, 0.5, 1, 2, 5],
  }),
};
```

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Quub Integration",
    "panels": [
      {
        "title": "API Call Rate",
        "targets": [
          {
            "expr": "rate(quub_api_calls_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(quub_api_calls_total{status=~\"5..\"}[5m])"
          }
        ]
      }
    ]
  }
}
```

## Alerting

### CloudWatch Alarms

```terraform
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "quub-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

---

**Next Steps:**

- [Monitoring Guide]({{ '/guides/getting-started/deployment-guide/#monitoring--alerting' | relative_url }})
- [Security Guide]({{ '/guides/getting-started/security-guide/' | relative_url }})
- [Performance Optimization]({{ '/guides/getting-started/performance-optimization/' | relative_url }})

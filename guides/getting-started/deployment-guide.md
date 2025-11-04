---
layout: docs
title: Deployment Guide
permalink: /guides/getting-started/deployment-guide/
description: Production deployment strategies and best practices for Quub Exchange integrations
---

# Deployment Guide

Comprehensive guide for deploying your Quub Exchange integration to production environments with confidence.

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Deployment Strategies](#deployment-strategies)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Infrastructure as Code](#infrastructure-as-code)
6. [Monitoring & Alerting](#monitoring--alerting)
7. [Disaster Recovery](#disaster-recovery)

---

## Pre-Deployment Checklist

### Security Checklist

- [ ] **API Keys**

  - [ ] Production API keys generated
  - [ ] Keys stored in secret manager (not in code)
  - [ ] Separate keys for each environment
  - [ ] IP whitelist configured
  - [ ] Key rotation schedule set

- [ ] **Authentication**

  - [ ] MFA enabled for admin accounts
  - [ ] JWT token expiration configured (≤ 1 hour)
  - [ ] Refresh token rotation enabled
  - [ ] Session timeout configured

- [ ] **Network Security**

  - [ ] HTTPS enforced
  - [ ] TLS 1.2+ configured
  - [ ] Certificate pinning implemented
  - [ ] Firewall rules configured
  - [ ] DDoS protection enabled

- [ ] **Data Protection**
  - [ ] Sensitive data encrypted at rest
  - [ ] PII properly masked in logs
  - [ ] Backup encryption enabled
  - [ ] Data retention policy configured

### Performance Checklist

- [ ] **Caching**

  - [ ] Redis/caching layer configured
  - [ ] Cache invalidation strategy defined
  - [ ] TTL values optimized
  - [ ] Cache hit rate monitored

- [ ] **Database**

  - [ ] Indexes created
  - [ ] Connection pooling configured
  - [ ] Query performance tested
  - [ ] Backup strategy in place

- [ ] **API Client**

  - [ ] Connection pooling enabled
  - [ ] Timeout values configured
  - [ ] Retry logic implemented
  - [ ] Rate limiting configured

- [ ] **Monitoring**
  - [ ] APM tool configured (New Relic, Datadog)
  - [ ] Logging centralized
  - [ ] Error tracking enabled (Sentry)
  - [ ] Alerts configured

### Testing Checklist

- [ ] **Unit Tests**

  - [ ] All critical paths covered
  - [ ] Test coverage > 80%
  - [ ] Mock Quub API responses
  - [ ] Edge cases tested

- [ ] **Integration Tests**

  - [ ] Sandbox environment tested
  - [ ] End-to-end flows validated
  - [ ] Error scenarios tested
  - [ ] WebSocket connections tested

- [ ] **Load Tests**

  - [ ] Peak load tested (2x expected traffic)
  - [ ] Sustained load tested (24+ hours)
  - [ ] Rate limits validated
  - [ ] Circuit breakers tested

- [ ] **Security Tests**
  - [ ] Penetration testing completed
  - [ ] Dependency vulnerabilities scanned
  - [ ] API key exposure checked
  - [ ] OWASP top 10 validated

---

## Environment Setup

### Environment Configuration

```javascript
// config/environments.js
const environments = {
  development: {
    quub: {
      apiUrl: "https://api-sandbox.quub.fi",
      wsUrl: "wss://ws-sandbox.quub.fi",
      apiKey: process.env.QUUB_DEV_API_KEY,
      apiSecret: process.env.QUUB_DEV_API_SECRET,
      orgId: process.env.QUUB_DEV_ORG_ID,
    },
    database: {
      host: "localhost",
      port: 5432,
      database: "quub_dev",
    },
    redis: {
      host: "localhost",
      port: 6379,
    },
  },

  staging: {
    quub: {
      apiUrl: "https://api-sandbox.quub.fi",
      wsUrl: "wss://ws-sandbox.quub.fi",
      apiKey: process.env.QUUB_STAGING_API_KEY,
      apiSecret: process.env.QUUB_STAGING_API_SECRET,
      orgId: process.env.QUUB_STAGING_ORG_ID,
    },
    database: {
      host: process.env.DB_HOST,
      port: 5432,
      database: "quub_staging",
    },
    redis: {
      host: process.env.REDIS_HOST,
      port: 6379,
    },
  },

  production: {
    quub: {
      apiUrl: "https://api.quub.fi",
      wsUrl: "wss://ws.quub.fi",
      apiKey: process.env.QUUB_PROD_API_KEY,
      apiSecret: process.env.QUUB_PROD_API_SECRET,
      orgId: process.env.QUUB_PROD_ORG_ID,
    },
    database: {
      host: process.env.DB_HOST,
      port: 5432,
      database: "quub_production",
      ssl: true,
      replication: {
        read: [process.env.DB_READ_REPLICA_1, process.env.DB_READ_REPLICA_2],
      },
    },
    redis: {
      cluster: [
        { host: process.env.REDIS_NODE_1, port: 6379 },
        { host: process.env.REDIS_NODE_2, port: 6379 },
        { host: process.env.REDIS_NODE_3, port: 6379 },
      ],
    },
  },
};

export function getConfig() {
  const env = process.env.NODE_ENV || "development";
  return environments[env];
}
```

### Secret Management

**AWS Secrets Manager:**

```javascript
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";

class SecretManager {
  constructor() {
    this.client = new SecretsManagerClient({
      region: process.env.AWS_REGION,
    });
    this.cache = new Map();
  }

  async getSecret(secretName) {
    // Check cache
    if (this.cache.has(secretName)) {
      const cached = this.cache.get(secretName);
      if (Date.now() - cached.timestamp < 3600000) {
        // 1 hour
        return cached.value;
      }
    }

    // Fetch from AWS
    const response = await this.client.send(
      new GetSecretValueCommand({ SecretId: secretName })
    );

    const secret = JSON.parse(response.SecretString);

    // Cache
    this.cache.set(secretName, {
      value: secret,
      timestamp: Date.now(),
    });

    return secret;
  }

  async getQuubCredentials() {
    const env = process.env.NODE_ENV;
    return await this.getSecret(`${env}/quub/credentials`);
  }
}

export const secretManager = new SecretManager();
```

**HashiCorp Vault:**

```javascript
import vault from "node-vault";

class VaultSecretManager {
  constructor() {
    this.client = vault({
      apiVersion: "v1",
      endpoint: process.env.VAULT_ADDR,
      token: process.env.VAULT_TOKEN,
    });
  }

  async getQuubCredentials() {
    const env = process.env.NODE_ENV;
    const path = `secret/data/${env}/quub`;

    const response = await this.client.read(path);
    return response.data.data;
  }
}
```

---

## Deployment Strategies

### Blue-Green Deployment

```javascript
// deployment/blue-green.js
class BlueGreenDeployment {
  constructor(loadBalancer) {
    this.lb = loadBalancer;
  }

  async deploy(newVersion) {
    console.log("🚀 Starting blue-green deployment...");

    // Step 1: Deploy to green environment
    console.log("📦 Deploying to green environment...");
    await this.deployToGreen(newVersion);

    // Step 2: Health check
    console.log("🏥 Running health checks...");
    const healthy = await this.healthCheck("green");

    if (!healthy) {
      console.error("❌ Health check failed, aborting deployment");
      await this.rollbackGreen();
      return false;
    }

    // Step 3: Smoke tests
    console.log("🧪 Running smoke tests...");
    const testsPass = await this.runSmokeTests("green");

    if (!testsPass) {
      console.error("❌ Smoke tests failed, aborting deployment");
      await this.rollbackGreen();
      return false;
    }

    // Step 4: Gradually shift traffic
    console.log("🔀 Shifting traffic...");
    await this.shiftTraffic("blue", "green", [
      { blue: 90, green: 10 },
      { blue: 70, green: 30 },
      { blue: 50, green: 50 },
      { blue: 30, green: 70 },
      { blue: 10, green: 90 },
      { blue: 0, green: 100 },
    ]);

    // Step 5: Monitor for issues
    console.log("📊 Monitoring...");
    await this.monitor("green", 600000); // 10 minutes

    // Step 6: Complete switch
    console.log("✅ Deployment complete!");
    await this.lb.setActive("green");
    await this.lb.setInactive("blue");

    return true;
  }

  async shiftTraffic(from, to, steps) {
    for (const step of steps) {
      await this.lb.setWeights({
        [from]: step[from],
        [to]: step[to],
      });

      console.log(`  Traffic: ${step[from]}% ${from}, ${step[to]}% ${to}`);

      // Wait and monitor
      await this.sleep(60000); // 1 minute

      const metrics = await this.getMetrics(to);
      if (metrics.errorRate > 0.01) {
        throw new Error("High error rate detected, aborting traffic shift");
      }
    }
  }
}
```

### Canary Deployment

```javascript
// deployment/canary.js
class CanaryDeployment {
  async deploy(newVersion) {
    console.log("🐤 Starting canary deployment...");

    // Step 1: Deploy canary
    await this.deployCanary(newVersion);

    // Step 2: Route 5% of traffic to canary
    await this.setCanaryTraffic(5);

    // Step 3: Monitor for 15 minutes
    console.log("📊 Monitoring canary (15 minutes)...");
    const canaryHealthy = await this.monitorCanary(900000);

    if (!canaryHealthy) {
      console.error("❌ Canary failed, rolling back");
      await this.removeCanary();
      return false;
    }

    // Step 4: Increase to 25%
    console.log("📈 Increasing canary traffic to 25%");
    await this.setCanaryTraffic(25);
    await this.monitorCanary(600000); // 10 minutes

    // Step 5: Increase to 50%
    console.log("📈 Increasing canary traffic to 50%");
    await this.setCanaryTraffic(50);
    await this.monitorCanary(600000);

    // Step 6: Full rollout
    console.log("✅ Promoting canary to production");
    await this.promoteCanary();

    return true;
  }

  async monitorCanary(duration) {
    const startTime = Date.now();

    while (Date.now() - startTime < duration) {
      const canaryMetrics = await this.getMetrics("canary");
      const productionMetrics = await this.getMetrics("production");

      // Compare error rates
      if (canaryMetrics.errorRate > productionMetrics.errorRate * 1.5) {
        console.error("❌ Canary error rate too high");
        return false;
      }

      // Compare latency
      if (canaryMetrics.latencyP99 > productionMetrics.latencyP99 * 1.3) {
        console.warn("⚠️ Canary latency elevated");
      }

      await this.sleep(30000); // Check every 30 seconds
    }

    return true;
  }
}
```

### Rolling Deployment

```javascript
// deployment/rolling.js
class RollingDeployment {
  async deploy(newVersion, servers) {
    console.log("🔄 Starting rolling deployment...");

    const batchSize = Math.ceil(servers.length / 4); // 25% at a time

    for (let i = 0; i < servers.length; i += batchSize) {
      const batch = servers.slice(i, i + batchSize);

      console.log(`📦 Deploying to batch ${Math.floor(i / batchSize) + 1}...`);

      // Remove from load balancer
      await this.removeFromLoadBalancer(batch);

      // Deploy new version
      await Promise.all(
        batch.map((server) => this.deployToServer(server, newVersion))
      );

      // Health check
      const healthy = await Promise.all(
        batch.map((server) => this.healthCheck(server))
      );

      if (!healthy.every((h) => h)) {
        console.error("❌ Health check failed, rolling back");
        await this.rollbackBatch(batch);
        return false;
      }

      // Add back to load balancer
      await this.addToLoadBalancer(batch);

      // Wait and monitor
      await this.sleep(60000);
    }

    console.log("✅ Rolling deployment complete");
    return true;
  }
}
```

---

## CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm test

      - name: Run integration tests
        run: npm run test:integration
        env:
          QUUB_API_KEY: ${{ secrets.QUUB_STAGING_API_KEY }}
          QUUB_API_SECRET: ${{ secrets.QUUB_STAGING_API_SECRET }}
          QUUB_ORG_ID: ${{ secrets.QUUB_STAGING_ORG_ID }}

      - name: Run security scan
        run: npm audit --audit-level=high

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: |
          docker build -t quub-app:${{ github.sha }} .
          docker tag quub-app:${{ github.sha }} quub-app:latest

      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push quub-app:${{ github.sha }}
          docker push quub-app:latest

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          kubectl set image deployment/quub-app \
            quub-app=quub-app:${{ github.sha }} \
            --namespace=staging

      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/quub-app \
            --namespace=staging \
            --timeout=5m

      - name: Run smoke tests
        run: npm run test:smoke
        env:
          API_URL: https://staging.example.com

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production
        run: |
          kubectl set image deployment/quub-app \
            quub-app=quub-app:${{ github.sha }} \
            --namespace=production

      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/quub-app \
            --namespace=production \
            --timeout=10m

      - name: Verify deployment
        run: npm run verify:production

      - name: Notify team
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: "Production deployment: ${{ job.status }}"
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Dockerfile

```dockerfile
# Multi-stage build
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source
COPY . .

# Build
RUN npm run build

# Production image
FROM node:18-alpine

WORKDIR /app

# Copy from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

---

## Infrastructure as Code

### Terraform

```hcl
# terraform/main.tf

# ECS Cluster
resource "aws_ecs_cluster" "quub_app" {
  name = "quub-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "quub_app" {
  family                   = "quub-app"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "1024"
  memory                  = "2048"

  container_definitions = jsonencode([{
    name  = "quub-app"
    image = "${var.docker_image}:${var.version}"

    environment = [
      { name = "NODE_ENV", value = "production" },
      { name = "QUUB_API_URL", value = "https://api.quub.fi" }
    ]

    secrets = [
      {
        name      = "QUUB_API_KEY"
        valueFrom = aws_secretsmanager_secret.quub_api_key.arn
      },
      {
        name      = "QUUB_API_SECRET"
        valueFrom = aws_secretsmanager_secret.quub_api_secret.arn
      }
    ]

    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/quub-app"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
}

# ECS Service
resource "aws_ecs_service" "quub_app" {
  name            = "quub-app-service"
  cluster         = aws_ecs_cluster.quub_app.id
  task_definition = aws_ecs_task_definition.quub_app.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.quub_app.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.quub_app.arn
    container_name   = "quub-app"
    container_port   = 3000
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100

    deployment_circuit_breaker {
      enable   = true
      rollback = true
    }
  }
}

# Auto Scaling
resource "aws_appautoscaling_target" "quub_app" {
  max_capacity       = 10
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.quub_app.name}/${aws_ecs_service.quub_app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "quub_app_cpu" {
  name               = "quub-app-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.quub_app.resource_id
  scalable_dimension = aws_appautoscaling_target.quub_app.scalable_dimension
  service_namespace  = aws_appautoscaling_target.quub_app.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
```

---

## Monitoring & Alerting

### Prometheus + Grafana

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "quub-app"
    static_configs:
      - targets: ["app:3000"]
    metrics_path: "/metrics"
```

```javascript
// metrics.js
import { register, Counter, Histogram, Gauge } from "prom-client";

export const metrics = {
  apiCalls: new Counter({
    name: "quub_api_calls_total",
    help: "Total Quub API calls",
    labelNames: ["endpoint", "method", "status"],
  }),

  apiLatency: new Histogram({
    name: "quub_api_latency_seconds",
    help: "Quub API latency",
    labelNames: ["endpoint"],
    buckets: [0.1, 0.5, 1, 2, 5],
  }),

  activeOrders: new Gauge({
    name: "quub_active_orders",
    help: "Number of active orders",
  }),
};

// Expose metrics endpoint
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});
```

### CloudWatch Alarms

```hcl
# terraform/monitoring.tf

resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "quub-app-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors error rate"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "quub-app-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"
  alarm_description   = "This metric monitors latency"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

---

## Disaster Recovery

### Backup Strategy

```javascript
// backup.js
import cron from "node-cron";

// Daily database backup
cron.schedule("0 2 * * *", async () => {
  console.log("🔄 Starting database backup...");

  try {
    await execCommand(`
      pg_dump ${process.env.DB_NAME} | \
      gzip | \
      aws s3 cp - s3://backups/db-$(date +%Y%m%d).sql.gz
    `);

    console.log("✅ Database backup complete");
  } catch (error) {
    console.error("❌ Backup failed:", error);
    await alertOps("Database backup failed");
  }
});

// Backup retention (keep 30 days)
cron.schedule("0 3 * * *", async () => {
  await execCommand(`
    aws s3 ls s3://backups/ | \
    awk '{print $4}' | \
    head -n -30 | \
    xargs -I {} aws s3 rm s3://backups/{}
  `);
});
```

### Disaster Recovery Plan

```javascript
// disaster-recovery.js
class DisasterRecovery {
  async failover() {
    console.log("🚨 Starting failover to DR region...");

    // Step 1: Update DNS
    await this.updateDNS({
      recordName: "api.example.com",
      newTarget: "dr-lb.us-west-2.elb.amazonaws.com",
    });

    // Step 2: Promote DR database
    await this.promoteDatabase("dr-replica");

    // Step 3: Scale up DR services
    await this.scaleServices("us-west-2", { minSize: 3, desiredSize: 5 });

    // Step 4: Verify services
    await this.verifyServices("us-west-2");

    console.log("✅ Failover complete");
  }

  async recover() {
    console.log("🔄 Starting recovery to primary region...");

    // Step 1: Restore database
    await this.restoreDatabase("latest-backup");

    // Step 2: Deploy application
    await this.deployServices("us-east-1");

    // Step 3: Sync data from DR
    await this.syncData("us-west-2", "us-east-1");

    // Step 4: Update DNS
    await this.updateDNS({
      recordName: "api.example.com",
      newTarget: "primary-lb.us-east-1.elb.amazonaws.com",
    });

    console.log("✅ Recovery complete");
  }
}
```

---

**Need Deployment Help?** Contact devops@quub.fi | See [Deployment Checklist](../deployment-checklist/)

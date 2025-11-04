---
layout: docs
title: Welcome to Quub Exchange Documentation
description: Comprehensive guides and API documentation for the Quub Exchange platform
---

# Welcome to Quub Exchange Documentation

Build powerful financial applications with Quub Exchange's comprehensive suite of APIs and services. Whether you're integrating trading, custody, or compliance features, we've got you covered.

<div class="callout info">
  <strong>🚀 New to Quub?</strong> Start with our <a href="{{ '/docs/quickstart/' | relative_url }}">Quick Start Guide</a> to get up and running in minutes.
</div>

## 🎯 Popular Topics

<div class="topic-grid">
  <a href="{{ '/docs/authentication/' | relative_url }}" class="topic-card">
    <div class="topic-icon">🔐</div>
    <h3>Authentication</h3>
    <p>Learn how to authenticate and secure your API requests</p>
  </a>

  <a href="{{ '/capabilities/exchange/api-documentation/' | relative_url }}" class="topic-card">
    <div class="topic-icon">💱</div>
    <h3>Trading APIs</h3>
    <p>Execute trades and manage orders programmatically</p>
  </a>

  <a href="{{ '/capabilities/custodian/api-documentation/' | relative_url }}" class="topic-card">
    <div class="topic-icon">🏦</div>
    <h3>Custody Services</h3>
    <p>Securely manage digital assets and wallets</p>
  </a>

  <a href="{{ '/docs/webhooks/' | relative_url }}" class="topic-card">
    <div class="topic-icon">🔔</div>
    <h3>Webhooks & Events</h3>
    <p>Get real-time notifications for important events</p>
  </a>
</div>

## 📚 API Reference

Explore our complete API documentation organized by service category:

### Core Platform

- [**Auth Service**]({{ '/capabilities/auth/api-documentation/' | relative_url }}) - Authentication and session management
- [**Identity Service**]({{ '/capabilities/identity/api-documentation/' | relative_url }}) - User identity and KYC
- [**Tenancy & Trust**]({{ '/capabilities/tenancy-trust/api-documentation/' | relative_url }}) - Multi-tenant security

### Trading & Markets

- [**Exchange**]({{ '/capabilities/exchange/api-documentation/' | relative_url }}) - Order execution and trading
- [**Marketplace**]({{ '/capabilities/marketplace/api-documentation/' | relative_url }}) - P2P trading and liquidity
- [**Gateway**]({{ '/capabilities/gateway/api-documentation/' | relative_url }}) - Multi-venue routing
- [**Market Oracles**]({{ '/capabilities/market-oracles/api-documentation/' | relative_url }}) - Price feeds and data
- [**Pricing & RefData**]({{ '/capabilities/pricing-refdata/api-documentation/' | relative_url }}) - Market data reference

### Financial Services

- [**Custodian**]({{ '/capabilities/custodian/api-documentation/' | relative_url }}) - Asset custody and wallets
- [**Treasury**]({{ '/capabilities/treasury/api-documentation/' | relative_url }}) - Treasury management
- [**Fiat Banking**]({{ '/capabilities/fiat-banking/api-documentation/' | relative_url }}) - Banking rails integration
- [**Settlements**]({{ '/capabilities/settlements/api-documentation/' | relative_url }}) - Settlement processing
- [**Escrow**]({{ '/capabilities/escrow/api-documentation/' | relative_url }}) - Escrow services
- [**Fees & Billing**]({{ '/capabilities/fees-billing/api-documentation/' | relative_url }}) - Fee calculation and billing

## 🛠️ Developer Tools

- **[OpenAPI Specifications]({{ '/openapi/' | relative_url }})** - Download machine-readable API specs
- **[Postman Collection](#)** - Import and test APIs with Postman
- **[SDKs & Libraries](#)** - Official client libraries for popular languages
- **[Sandbox Environment]({{ '/capabilities/sandbox/api-documentation/' | relative_url }})** - Test safely in our sandbox

## 💡 Guides & Tutorials

- [**Getting Started**]({{ '/docs/quickstart/' | relative_url }}) - Your first API call in 5 minutes
- [**Authentication Guide**]({{ '/docs/authentication/' | relative_url }}) - Secure your integrations
- [**Best Practices**]({{ '/docs/best-practices/' | relative_url }}) - Production-ready patterns
- [**Error Handling**]({{ '/docs/errors/' | relative_url }}) - Handle errors gracefully
- [**Rate Limiting**]({{ '/docs/rate-limits/' | relative_url }}) - Optimize API usage

## 🆘 Support

Need help? We're here for you:

- **[Community Forum](#)** - Ask questions and share knowledge
- **[Support Portal](#)** - Get help from our team
- **[Status Page](#)** - Check system status
- **[GitHub Issues](https://github.com/{{ site.repository }}/issues)** - Report bugs or suggest features

---

<div class="text-center mt-4">
  <p><strong>Ready to get started?</strong></p>
  <a href="{{ '/docs/quickstart/' | relative_url }}" class="btn-primary">View Quick Start Guide →</a>
</div>

<style>
.topic-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmin(250px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.topic-card {
  padding: 1.5rem;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  text-decoration: none;
  transition: all var(--transition-fast);
}

.topic-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
  border-color: var(--primary);
}

.topic-icon {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

.topic-card h3 {
  margin: 0 0 0.5rem 0;
  color: var(--text-primary);
  font-size: 1.25rem;
}

.topic-card p {
  margin: 0;
  color: var(--text-secondary);
  font-size: 0.875rem;
}

.btn-primary {
  display: inline-block;
  padding: 0.75rem 2rem;
  background: var(--primary);
  color: white;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  transition: all var(--transition-fast);
}

.btn-primary:hover {
  background: var(--primary-hover);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}
</style>

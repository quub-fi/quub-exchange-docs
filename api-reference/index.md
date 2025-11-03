---
layout: docs
title: API Reference
description: Complete API documentation for all Quub Exchange services
---

# API Reference

Interactive API documentation powered by OpenAPI specifications. Select a service to explore its endpoints, request/response schemas, and try it out in real-time.

## 📱 Available APIs

### 🔐 Core Platform

<div class="api-list">
  <a href="{{ '/api-reference/auth/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-key"></i> Authentication Service</h3>
    <p>User authentication, session management, and access control</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/identity/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-user-shield"></i> Identity Service</h3>
    <p>User identity, KYC/AML, and profile management</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/tenancy-trust/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-building"></i> Tenancy & Trust</h3>
    <p>Multi-tenant isolation and trust management</p>
    <span class="api-version">v2.0.0</span>
  </a>
</div>

### 💱 Trading & Markets

<div class="api-list">
  <a href="{{ '/api-reference/exchange/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-exchange-alt"></i> Exchange</h3>
    <p>Order execution, matching engine, and trade management</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/marketplace/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-store"></i> Marketplace</h3>
    <p>P2P trading, liquidity pools, and secondary markets</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/gateway/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-network-wired"></i> Gateway</h3>
    <p>Multi-venue routing and aggregation</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/market-oracles/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-chart-line"></i> Market Oracles</h3>
    <p>Price feeds, market data, and oracle services</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/pricing-refdata/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-database"></i> Pricing & RefData</h3>
    <p>Pricing engines and reference data management</p>
    <span class="api-version">v2.0.0</span>
  </a>
</div>

### 🏦 Financial Services

<div class="api-list">
  <a href="{{ '/api-reference/custodian/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-vault"></i> Custodian</h3>
    <p>Asset custody, wallet management, and security</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/treasury/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-coins"></i> Treasury</h3>
    <p>Treasury operations and cash management</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/fiat-banking/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-university"></i> Fiat Banking</h3>
    <p>Banking rails integration and fiat operations</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/settlements/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-handshake"></i> Settlements</h3>
    <p>Settlement processing and reconciliation</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/escrow/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-lock"></i> Escrow</h3>
    <p>Escrow services and conditional transfers</p>
    <span class="api-version">v2.0.0</span>
  </a>

  <a href="{{ '/api-reference/fees-billing/' | relative_url }}" class="api-card">
    <h3><i class="fas fa-file-invoice-dollar"></i> Fees & Billing</h3>
    <p>Fee calculation, billing, and invoicing</p>
    <span class="api-version">v2.0.0</span>
  </a>
</div>

[View all 26 APIs →]({{ '/api-reference/all/' | relative_url }})

## 🛠️ Developer Resources

- **[OpenAPI Specifications]({{ '/openapi/' | relative_url }})** - Download raw OpenAPI YAML files
- **[Authentication Guide]({{ '/docs/authentication/' | relative_url }})** - Learn how to authenticate
- **[Rate Limits]({{ '/docs/rate-limits/' | relative_url }})** - Understand rate limiting
- **[Error Codes]({{ '/docs/errors/' | relative_url }})** - Common error responses
- **[Webhooks]({{ '/docs/webhooks/' | relative_url }})** - Real-time event notifications

<style>
.api-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.api-card {
  position: relative;
  padding: 1.5rem;
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  text-decoration: none;
  transition: all var(--transition-base);
  display: flex;
  flex-direction: column;
}

.api-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-xl);
  border-color: var(--primary);
}

.api-card h3 {
  margin: 0 0 0.75rem 0;
  color: var(--text-primary);
  font-size: 1.125rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.api-card h3 i {
  color: var(--primary);
}

.api-card p {
  margin: 0 0 1rem 0;
  color: var(--text-secondary);
  font-size: 0.875rem;
  flex-grow: 1;
}

.api-version {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background: rgba(99, 102, 241, 0.1);
  color: var(--primary);
  font-size: 0.75rem;
  font-weight: 600;
  border-radius: 4px;
}
</style>
